//
//  DownloadRequest.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 06.09.2022.
//

import Combine

final class DownloadRequest: Request, Publishable {
    typealias Publisher = URLSession.DownloadTaskPublisher
    typealias Subscriber = URLSession.DownloadTaskSubscriber
    
    let destination: DownloadDestination?
    let downloadProgress = Progress(totalUnitCount: 0)
    var downloadProgressCallback: Command<Progress>?
    var publisher: Publisher?
    var cancellable: AnyCancellable?
    
    lazy var subscriber: Subscriber = Subscriber(recieveInput: recieveInput,
                                                 recieveCompletion: recieveCommpletion)
    
    private lazy var recieveInput: Command<Subscriber.Input> = Command { input in
        guard let httpResponse = input.response as? HTTPURLResponse else {
            self.cancel()
            return
        }
        self.data = input.data
        self.responseCallback?.perform(value: httpResponse)
    }
    
    private lazy var recieveCommpletion: Command<Subscribers.Completion<Subscriber.Failure>> = Command { completion in
        switch completion {
        case .failure(let error):
            self.error = NetworkError(error)
        case .finished:
            return
        }
    }
    
    init(urlRequest: URLRequest, destination: DownloadDestination?) {
        self.destination = destination
        super.init(urlRequest: urlRequest)
    }
    
    func downloadProgress(queue: DispatchQueue = .main, closure: @escaping ProgressHandler) -> Self {
        downloadProgressCallback = Command { progress in
            closure(progress)
        }
        return self
    }
    
    func updateDownloadProgress(bytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        downloadProgress.totalUnitCount = totalBytesExpectedToWrite
        downloadProgress.completedUnitCount += bytesWritten

        downloadProgressCallback?.perform(value: downloadProgress)
    }
    
    func didCreatePublisher(_ publisher: Publisher) {
        self.publisher = publisher
    }
    
    @discardableResult
    func resume() -> Self {
        publisher?.subscribe(subscriber)
        return self
    }
}

extension DownloadRequest {
    @discardableResult
    func responseData(completionHandler: @escaping (AsyncDownloadResponse<Data>) -> Void) -> Self {
        responseCallback = Command { [weak self] urlResponse in
            guard let self = self else { return }
            let result = Result { () -> Data in
                guard let data = self.data else {
                    throw NetworkError.missingData
                }
                
                if let error = self.error {
                    throw error
                }
                
                return data
            }.mapError {
                NetworkError($0)
            }
            
            let response = DownloadResponse(urlRequest: self.urlRequest,
                                            response: urlResponse,
                                            destination: self.destination,
                                            result: result)
            completionHandler(response)
        }
        return self
    }
}
