//
//  ParameterEncoding.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 30.08.2022.
//

import Foundation

public typealias Parameters = [String: Any]

public enum ParameterEncoding {
    case url(URLEncoding)
    case json(JSONEcoding)
    
    public func encode(_ urlRequest: URLRequest,
                withParameters parameters: Parameters?,
                method: HTTPMethod) throws -> URLRequest {
        switch self {
        case .url(let urlEncoding):
            return try urlEncoding.encode(urlRequest,
                                          withParameters: parameters,
                                          method: method)
        case .json(let jsonEncoding):
            return try jsonEncoding.encode(urlRequest,
                                           withParameters: parameters)
        }
    }
}

// MARK: - URL
public enum URLEncoding {
    case `default`, query, httpBody
    
    public func encode(_ urlRequest: URLRequest,
                       withParameters parameters: Parameters?,
                       method: HTTPMethod) throws -> URLRequest {
        guard let parameters = parameters else { return urlRequest }
        var newUrlRequest = urlRequest
        
        if shouldEncodeInURL(for: method) {
            guard let url = newUrlRequest.url else {
                throw NetworkError.missingUrl
            }

            if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
                let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(parameters)
                urlComponents.percentEncodedQuery = percentEncodedQuery
                newUrlRequest.url = urlComponents.url
            }
        } else {
            if newUrlRequest.headers["Content-Type"] == nil {
                newUrlRequest.headers.update(.contentType("application/x-www-form-urlencoded; charset=utf-8"))
            }

            newUrlRequest.httpBody = Data(query(parameters).utf8)
        }

        return newUrlRequest
    }
    
    private func shouldEncodeInURL(for method: HTTPMethod) -> Bool {
        switch self {
        case .default: return [.get, .head, .delete].contains(method)
        case .query: return true
        case .httpBody: return false
        }
    }
    
    private func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
        switch value {
        case let dictionary as [String: Any]:
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        case let array as [Any]:
            for value in array {
                components += queryComponents(fromKey: "\(key)[]", value: value)
            }
        case let number as NSNumber:
            if String(cString: number.objCType) == "c" {
                components.append((escape(key), escape("\(number.boolValue.toInt)")))
            } else {
                components.append((escape(key), escape("\(number)")))
            }
        case let bool as Bool:
            components.append((escape(key), escape("\(bool.toInt)")))
        default:
            components.append((escape(key), escape("\(value)")))
        }
        return components
    }

    private func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="
        let encodableDelimiters = CharacterSet(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return string.addingPercentEncoding(withAllowedCharacters:
                                                    .urlQueryAllowed.subtracting(encodableDelimiters)) ?? string
    }

    private func query(_ parameters: [String: Any]) -> String {
        var components: [(String, String)] = []

        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
}

// MARK: - JSON
public enum JSONEcoding {
    case `default`, prettyPrinted
    
    var options: JSONSerialization.WritingOptions {
        switch self {
        case .default:
            return []
        case .prettyPrinted:
            return .prettyPrinted
        }
    }
    
    public func encode(_ urlRequest: URLRequest,
                       withParameters parameters: Parameters?) throws -> URLRequest {
        guard let parameters = parameters else { return urlRequest }
        var newUrlRequest = urlRequest

        do {
            let data = try JSONSerialization.data(withJSONObject: parameters, options: options)

            if newUrlRequest.headers["Content-Type"] == nil {
                newUrlRequest.headers.update(.contentType("application/json"))
            }

            newUrlRequest.httpBody = data
        } catch {
            throw NetworkError.jsonEncodingFailed(error: error)
        }

        return newUrlRequest
    }
}
