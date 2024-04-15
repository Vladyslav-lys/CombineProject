//
//  CachedRequestConvertible.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 05.09.2022.
//

import Foundation

struct CachedRequestConvertible: RequestConvertible {
    let baseURL: URL?
    let path: String
    let method: HTTPMethod
    let task: Network.Task
    let headers: HTTPHeaders?
    let retryEnabled: Bool
    let authorizationStrategy: AuthorizationStrategy?

    init(_ target: RequestConvertible) {
        baseURL = target.baseURL
        path = target.path
        method = target.method
        task = target.task
        headers = target.headers
        retryEnabled = target.retryEnabled
        authorizationStrategy = target.authorizationStrategy
    }
}
