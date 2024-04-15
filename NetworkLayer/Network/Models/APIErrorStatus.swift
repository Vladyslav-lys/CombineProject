//
//  APIErrorStatus.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 29.08.2022.
//

import Foundation

public extension APIError {
    enum Status {
        case unauthorized
        case paymentRequired
        case forbidden
        case notFound
        case methodNotAllowed
        case notAcceptable
        case requestTimeout
        case unprocessable
        case otherServerError
        case badGateway
        case gatewayTimeout
        case other
    }
}
