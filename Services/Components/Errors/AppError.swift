//
//  AppError.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 04.10.2022.
//

import NetworkLayer

public enum AppError: Error {
    case network(error: NetworkError)
    case database(error: Error)
    case keychain(error: KeychainStoredError)
    case permissions(message: String)
    case underlying(error: Error)
    case completeOrderError(message: String)
    case sessionRequired
    case undefined
}

extension AppError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .network(let error):
            return error.errorDescription
        case .database(let error):
            return error.localizedDescription
        case .underlying(let error):
            return error.localizedDescription
        case .sessionRequired:
            return "Session required!"
        case .permissions(let message):
            return message
        case .completeOrderError(let message):
            return message
        default:
            return nil
        }
    }
}
