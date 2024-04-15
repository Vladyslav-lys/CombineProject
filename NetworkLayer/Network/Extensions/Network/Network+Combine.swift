//
//  Network+Combine.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 05.09.2022.
//

import Combine

extension Network {
    public func request(_ request: RequestConvertible,
                        progress: ((Double) -> Void)? = nil,
                        qos: DispatchQoS.QoSClass = .default)
    -> AnyPublisher<Response, NetworkError> {
        Future<Response, NetworkError>({ [weak self] promise in
            guard let self = self else { return }
            self.request(request, qos: qos, progress: progress) { result in
                switch result {
                case .success(let response):
                    promise(.success(response))
                case .failure(let error):
                    promise(.failure(NetworkError(error)))
                }
            }
        }).eraseToAnyPublisher()
    }
}
