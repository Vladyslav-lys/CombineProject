//
//  NetworkPlugin.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 30.08.2022.
//

import Foundation

public protocol NetworkPlugin {
    func prepare(_ request: URLRequest,
                 target: RequestConvertible) throws -> URLRequest
    func willSend(_ request: Request,
                  target: RequestConvertible)
    func didReceive(_ result: Network.ResponseResult,
                    target: RequestConvertible)
    func process(_ result: Network.ResponseResult,
                 target: RequestConvertible) -> Network.ResponseResult
    func should(retry target: RequestConvertible,
                dueTo error: Error,
                completion: @escaping (RetryResult) -> Void)
}

extension NetworkPlugin {
    public func prepare(_ request: URLRequest,
                        target: RequestConvertible) -> URLRequest {
        request
    }

    public func willSend(_ request: Request, target: RequestConvertible) {}

    public func didReceive(_ result: Network.ResponseResult, target: RequestConvertible) {}

    public func process(_ result: Network.ResponseResult,
                        target: RequestConvertible) -> Network.ResponseResult {
        result
    }

    public func should(retry target: RequestConvertible,
                       dueTo error: Error,
                       completion: @escaping (RetryResult) -> Void) {
        completion(.doNotRetry)
    }
}
