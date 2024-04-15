//
//  Network+Response.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 30.08.2022.
//

import Foundation

extension Network {
    public class Response {
        let data: Data
        public let response: HTTPURLResponse
        public let request: URLRequest?
        let metrics: URLSessionTaskMetrics?

        var statusCode: Int {
            response.statusCode
        }

        public init(data: Data,
                    response: HTTPURLResponse,
                    request: URLRequest? = nil,
                    metrics: URLSessionTaskMetrics? = nil) {
            self.data = data
            self.request = request
            self.response = response
            self.metrics = metrics
        }
    }
}

extension Network.Response {
    public func decode<T: Decodable>(_ type: T.Type,
                                     decoder: JSONDecoder = JSONDecoder()) throws -> T {
        try decoder.decode(type, from: data)
    }
}
