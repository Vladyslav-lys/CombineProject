//
//  URLRequest+Encoding.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 02.09.2022.
//

import Foundation

extension URLRequest {
    func encoded(_ parameters: Encodable,
                 encoder: JSONEncoder = JSONEncoder()) throws -> URLRequest {
        do {
            var request = self
            let encodable = AnyEncodable(encodable: parameters)
            request.httpBody = try encoder.encode(encodable)
            let contentTypeHeaderName = "Content-Type"
            let contentType = request.value(forHTTPHeaderField: contentTypeHeaderName)
                ?? "application/json"
            request.setValue(contentType, forHTTPHeaderField: contentTypeHeaderName)
            return request
        } catch {
            throw NetworkError.parametersEncoding(error)
        }
    }

    func encoded(for target: RequestConvertible) throws -> URLRequest {
        switch target.task {
        case .requestData(let body):
            return with(self) { $0.httpBody = body }
        case .requestCompositeData(let body, let urlParameters):
            return try with(self) { $0.httpBody = body }
            .encoded(urlParameters, encoding: .url(.default), method: target.method)
        case .requestCompositeParameters(let bodyParameters,
                                         let bodyEncoding,
                                         let urlParameters):
            return try encoded(bodyParameters, encoding: bodyEncoding, method: target.method)
                .encoded(urlParameters, encoding: .url(.default), method: target.method)
        case .uploadCompositeMultipart(let urlParameters, _):
            return try encoded(urlParameters, encoding: .url(.default), method: target.method)
        case .downloadParameters(let parameters, let encoding, _):
            return try encoded(parameters, encoding: encoding, method: target.method)
        default:
            return self
        }
    }
    
    private func encoded(_ parameters: Parameters,
                         encoding: ParameterEncoding,
                         method: HTTPMethod) throws -> URLRequest {
        do {
            return try encoding.encode(self, withParameters: parameters, method: method)
        } catch {
            throw NetworkError.parametersEncoding(error)
        }
    }
}
