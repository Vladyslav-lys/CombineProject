//
//  APIErrorPlugin.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 30.08.2022.
//

import Foundation

public class APIErrorPlugin: NetworkPlugin {
    public init() {}
    
    public func process(_ result: Network.ResponseResult,
                        target: RequestConvertible) -> Network.ResponseResult {
        guard case .success(let response) = result,
              400 ..< 600 ~= response.statusCode else { return result }
        if let serverError = HTTPServerError(statusCode: response.statusCode) {
            return .failure(serverError)
        }
        
        do {
            let responseError = try response.decode(APIError.Response.self)
            let apiError = APIError(responseError, httpCode: response.statusCode)
            return .failure(apiError)
        } catch {
            return .failure(error)
        }
    }
}
