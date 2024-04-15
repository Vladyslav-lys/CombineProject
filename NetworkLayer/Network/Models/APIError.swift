//
//  APIError.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 29.08.2022.
//

import Foundation

public struct APIError: Decodable, LocalizedError {
    let error: String?
    let errors: [String]?
    let message: String
    public let httpCode: Int

    public var errorDescription: String? {
        if error == "invalid_grant" {
            return "Invalid credentials"
        }
        return errors?.first ?? message
    }
    
    public var status: Status {
        switch httpCode {
        case 401:
            return .unauthorized
        case 402:
            return .paymentRequired
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 405:
            return .methodNotAllowed
        case 406:
            return .notAcceptable
        case 408:
            return .requestTimeout
        case 422:
            return .unprocessable
        case 502:
            return .badGateway
        case 504:
            return .gatewayTimeout
        case 500..<600:
            return .otherServerError
        default:
            return .other
        }
    }
}

extension APIError {
    public init(_ response: Response, httpCode: Int) {
        error = response.error
        message = response.message
        errors = response.errors
        self.httpCode = httpCode
    }
}

extension APIError {
    public struct Response: Decodable {
        let error: String?
        let errors: [String]?
        let message: String
    }
}

extension Error {
    public var apiError: APIError? {
        if let apiError = self as? APIError {
            return apiError
        } else if let networkError = self as? NetworkError, case .api(let apiError) = networkError {
            return apiError
        } else if let networkError = self as? NetworkError, case .underlying(let someError) = networkError {
            return someError.apiError
        } else {
            return nil
        }
    }
    
    public var sessionTaskFailed: NetworkError? {
        if let error = self as? NetworkError, case .sessionTaskFailed = error {
            return error
        } else if let error = self as? NetworkError,
                  case .underlying(let underlyError) = error,
                  let networkError = underlyError as? NetworkError {
            return networkError.sessionTaskFailed
        }
        return nil
    }
}
