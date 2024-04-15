//
//  URLRequest+Init.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 02.09.2022.
//

import Foundation

extension URLRequest {
    public init(url: URL, method: HTTPMethod, headers: HTTPHeaders? = nil) throws {
        self.init(url: url)

        httpMethod = method.rawValue
        allHTTPHeaderFields = headers?.dictionary
    }
}
