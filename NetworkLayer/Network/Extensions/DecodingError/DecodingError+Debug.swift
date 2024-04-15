//
//  DecodingError+Debug.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 29.08.2022.
//

import Foundation

extension DecodingError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .dataCorrupted(let context):
            return "Data corrupted @ \(context.keyPath)"
        case .keyNotFound(let key, let context):
            return "Key '\(key.keyPath)' not found @ \(context.keyPath)"
        case .typeMismatch(let type, let context):
            return "Type mismatch '\(type)' @ \(context.keyPath)"
        case .valueNotFound(let type, let context):
            return "Value '\(type)' not found @ \(context.keyPath)"
        @unknown default:
            return "Unknown error"
        }
    }
}

private extension DecodingError.Context {
    var keyPath: String {
        codingPath.map { $0.keyPath }.joined(separator: ".")
    }
}

private extension CodingKey {
    var keyPath: String {
        intValue.flatMap(String.init) ?? stringValue
    }
}
