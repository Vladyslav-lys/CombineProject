//
//  Network.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 29.08.2022.
//

import Combine

final public class Network {
    public typealias ResponseResult = Result<Response, Error>
    public typealias MultipartFormDataBuilder = (MultipartFormData) -> Void
    public typealias Completion = (ResponseResult) -> Void

    private let session: NetworkSession
    private let baseURL: URL
    private let plugins: [NetworkPlugin]
    private var isInternetAvailable: Bool {
        NetworkReachabilityManager(host: baseURL.absoluteString)?.isReachable == true
    }

    // MARK: - Public
    public init(baseURL: URL,
                plugins: [NetworkPlugin] = [],
                commonHeaders: HTTPHeaders = .default) {
        self.baseURL = baseURL
        self.plugins = plugins
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.headers = commonHeaders
        session = NetworkSession(configuration: configuration, startRequestsImmediately: false)
    }
    
    @discardableResult
    func request(_ target: RequestConvertible,
                 qos: DispatchQoS.QoSClass = .default,
                 progress: ((Double) -> Void)? = nil,
                 completion: @escaping Completion) -> Cancellable {
        performRequest(CachedRequestConvertible(target),
                       queue: .global(qos: qos),
                       progress: progress,
                       completion: completion)
    }
    
    // MARK: - Private
    private func performRequest(_ target: RequestConvertible,
                                queue: DispatchQueue,
                                progress: ((Double) -> Void)? = nil,
                                completion: @escaping Completion) -> Cancellable {
        let token = CancellableToken()
        let commonCompletion: Completion = { [weak self] result in
            guard let self = self else { return }
            self.didReceive(result, target: target)
            let result = self.process(result, target: target)
            self.handleResult(result, target: target, queue: queue, token: token, completion: completion)
        }

        do {
            let urlRequest = try makeURLRequest(for: target)
            switch target.task {
            case .downloadDestination(let destination), .downloadParameters(_, _, let destination):
                return performDownload(urlRequest,
                                       destination: destination,
                                       token: token,
                                       target: target,
                                       progress: progress,
                                       completion: commonCompletion)
            case .uploadMultipart(let builder), .uploadCompositeMultipart(_, let builder):
                return performUpload(urlRequest,
                                     builder: builder,
                                     token: token,
                                     target: target,
                                     progress: progress,
                                     completion: commonCompletion)
            default:
                return performData(urlRequest,
                                   token: token,
                                   target: target,
                                   completion: commonCompletion)
            }
        } catch {
            queue.async {
                guard !token.isCancelled else { return }
                commonCompletion(.failure(error))
            }
            return token
        }
    }
}

// MARK: - Data request
extension Network {
    private func performData(_ request: URLRequest,
                             token: CancellableToken,
                             target: RequestConvertible,
                             completion: @escaping Completion) -> Cancellable {
        let task = session
            .request(request)
            .responseData { responseData in
                guard !token.isCancelled else { return }
                guard let response = responseData.response else {
                    return completion(.failure(self.performError(responseData.error)))
                }
                completion(Result { Response(data: responseData.data ?? Data(), response: response) })
            }
        token.didCancel {
            task.cancel()
        }
        willSend(task, target: target)
        task.resume()

        return token
    }
}

// MARK: - Download request
extension Network {
    private func performDownload(_ request: URLRequest,
                                 destination: DownloadDestination?,
                                 token: CancellableToken,
                                 target: RequestConvertible,
                                 progress: ((Double) -> Void)?,
                                 completion: @escaping Completion) -> Cancellable {
        let task = session
            .download(request, to: destination)
            .downloadProgress(closure: { progress?($0.fractionCompleted) })
            .responseData { responseData in
                guard !token.isCancelled else { return }
                guard let data = responseData.value, let response = responseData.response else {
                    return completion(.failure(self.performError(responseData.error)))
                }
                completion(Result { Response(data: data, response: response) })
            }
        token.didCancel {
            task.cancel()
        }
        willSend(task, target: target)
        task.resume()

        return token
    }
}

// MARK: - Upload request
extension Network {
    private func performUpload(_ request: URLRequest,
                               builder: MultipartFormDataBuilder,
                               token: CancellableToken,
                               target: RequestConvertible,
                               progress: ((Double) -> Void)?,
                               completion: @escaping Completion) -> Cancellable {
        let formData = MultipartFormData()
        builder(formData)
        
        let task = session
            .upload(multipartFormData: formData, with: request)
            .uploadProgress(closure: { progress?($0.fractionCompleted) })
            .responseData { [unowned self] responseData in
                guard !token.isCancelled else { return }
                guard let response = responseData.response else {
                    return completion(.failure(self.performError(responseData.error)))
                }
                completion(Result { Response(data: responseData.data ?? Data(), response: response) })
            }
        token.didCancel {
            task.cancel()
        }
        willSend(task, target: target)
        task.resume()

        return token
    }
}

// MARK: - Make URLRequest
extension Network {
    private func makeURLRequest(for target: RequestConvertible) throws -> URLRequest {
        let url = try makeBaseURL(for: target).appendingPathComponent(target.path)
        var request = try URLRequest(url: url).encoded(for: target)
        request.httpMethod = target.method.rawValue
        target.headers?.dictionary.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        return try prepare(request, target: target)
    }
    
    private func makeBaseURL(for target: RequestConvertible) throws -> URL {
        target.baseURL ?? baseURL
    }
}

// MARK: - Handle result
extension Network {
    private func handleResult(_ result: ResponseResult,
                              target: RequestConvertible,
                              queue: DispatchQueue,
                              token: CancellableToken,
                              completion: @escaping Completion) {
        guard case .failure(let error) = result else {
            completion(result)
            return
        }
        
        should(retry: target, dueTo: error, plugins: plugins) { [weak self] in
            guard let self = self else { return }
            switch $0 {
            case .doNotRetry:
                completion(result)
            case .doNotRetryWithError(let newError):
                completion(.failure(newError))
            case .retry:
                let innerToken = self.performRequest(target,
                                                     queue: queue,
                                                     completion: completion)
                token.didCancel {
                    innerToken.cancel()
                }
            case .retryWithDelay(let interval):
                queue.asyncAfter(deadline: .now() + interval) { [weak self] in
                    guard !token.isCancelled, let self = self else { return }
                    let innerToken = self.performRequest(target,
                                                         queue: queue,
                                                         completion: completion)
                    token.didCancel {
                        innerToken.cancel()
                    }
                }
            }
        }
    }
    
    private func performError(_ error: Error?) -> NetworkError {
        isInternetAvailable ? NetworkError(error) : NetworkError.noInternetConnection
    }
}

// MARK: - Handle NetworkPlugin methods
extension Network {
    private func prepare(_ request: URLRequest,
                         target: RequestConvertible) throws -> URLRequest {
        try plugins.reduce(request) { try $1.prepare($0, target: target) }
    }

    private func willSend(_ request: Request, target: RequestConvertible) {
        plugins.forEach { $0.willSend(request, target: target) }
    }

    private func didReceive(_ result: ResponseResult,
                            target: RequestConvertible) {
        plugins.forEach { $0.didReceive(result, target: target) }
    }

    private func process(_ result: ResponseResult,
                         target: RequestConvertible) -> ResponseResult {
        plugins.reduce(result) { $1.process($0, target: target) }
    }
}

// MARK: - Handle RequestRetrier methods
extension Network {
    private func should(retry target: RequestConvertible,
                        dueTo error: Error,
                        plugins: [NetworkPlugin],
                        completion: @escaping (RetryResult) -> Void) {
        guard target.retryEnabled, let plugin = plugins.first else {
            completion(.doNotRetry)
            return
        }
       
        plugin.should(retry: target, dueTo: error) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .doNotRetry:
                self.should(retry: target,
                            dueTo: error,
                            plugins: Array(plugins.dropFirst()),
                            completion: completion)
            default:
                completion(result)
            }
        }
    }
}
