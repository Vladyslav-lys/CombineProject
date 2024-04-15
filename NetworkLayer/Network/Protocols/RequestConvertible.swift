//
//  RequestConvertible.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 30.08.2022.
//

import Foundation

public protocol RequestConvertible {
    var baseURL: URL? { get }

    var path: String { get }

    var method: HTTPMethod { get }

    var task: Network.Task { get }

    var headers: HTTPHeaders? { get }
    
    var retryEnabled: Bool { get }

    var authorizationStrategy: AuthorizationStrategy? { get }
}

extension RequestConvertible {
    public var baseURL: URL? { nil }

    public var headers: HTTPHeaders? { nil }

    public var retryEnabled: Bool { true }

    public var authorizationStrategy: AuthorizationStrategy? { .token }
    
    public var retrierConfig: Bool { true }
}
