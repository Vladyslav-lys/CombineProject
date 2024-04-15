//
//  AuthorizationStrategy.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 30.08.2022.
//

import Combine

public protocol RefreshTokenProvider: AnyObject {
    func refreshToken() -> AnyPublisher<Void, Error>
}

public enum AuthorizationStrategy {
    case token
}

final public class AuthorizationPlugin: NetworkPlugin {
    private var accessToken: AccessToken?
    private var cancallable: AnyCancellable?
    public weak var refreshTokenProvider: RefreshTokenProvider?
    
    public init() {}
    
    deinit {
        cancallable?.cancel()
        cancallable = nil
    }

    public func setAccessToken(_ accessToken: AccessToken?) {
        self.accessToken = accessToken
    }

    public func prepare(_ request: URLRequest, target: RequestConvertible) throws -> URLRequest {
        return try with(request) {
            guard target.authorizationStrategy == .token else { return }
            guard let accessToken = accessToken else { throw NetworkError.sessionRequired }
            $0.headers.add(accessToken.authorizationHeader)
        }
    }

    public func should(retry target: RequestConvertible,
                       dueTo error: Error,
                       completion: @escaping (RetryResult) -> Void) {
        guard let provider = refreshTokenProvider, error.apiError?.httpCode == 401 else {
            completion(.doNotRetry)
            return
        }
        cancallable = provider.refreshToken().sink { result in
            guard case .failure(let error) = result else { return }
            completion(.doNotRetryWithError(error))
        } receiveValue: { _ in
            completion(.retry)
        }
    }
}
