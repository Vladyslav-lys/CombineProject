//
//  RetryResult.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 30.08.2022.
//

import Foundation

public enum RetryResult {
    case retry
    case retryWithDelay(TimeInterval)
    case doNotRetry
    case doNotRetryWithError(Error)
}

extension RetryResult {
    var retryRequired: Bool {
        switch self {
        case .retry, .retryWithDelay: return true
        default: return false
        }
    }

    var delay: TimeInterval? {
        switch self {
        case let .retryWithDelay(delay): return delay
        default: return nil
        }
    }

    var error: Error? {
        guard case let .doNotRetryWithError(error) = self else { return nil }
        return error
    }
}
