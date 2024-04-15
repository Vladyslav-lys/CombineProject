//
//  NetworkError.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 29.08.2022.
//

import Foundation

public enum NetworkError: Error {
    case missingResponse
    case missingUrl
    case missingData
    case jsonEncodingFailed(error: Error)
    case sessionRequired
    case parametersEncoding(Error)
    case underlying(Error)
    case decoding(DecodingError, URL?)
    case api(APIError)
    case noInternetConnection
    case sessionTaskFailed(Error)
    case outputStreamFileAlreadyExists
    case outputStreamURLInvalid
    case outputStreamCreationFailed
    case outputStreamWriteFailed(Error)
    case inputStreamReadFailed(Error)
    case noFileURL
    case failedFileURLCasting
    case unknown
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .missingResponse:
            return "Missing response from server"
        case .missingData:
            return "Missing data"
        case .missingUrl:
            return "Missing url"
        case .jsonEncodingFailed(let error):
            return "JSON encoding error: \(error.localizedDescription)"
        case .sessionRequired:
            return "Session is required"
        case .parametersEncoding:
            return "Failed to encode request parameters"
        case .underlying(let error):
            return error.localizedDescription
        case .api(let error):
            return error.localizedDescription
        case let .decoding(error, url):
            return handleDecodingError(error, url: url)
        case .noInternetConnection:
            return "No internet connection"
        case .sessionTaskFailed(let error):
            return error.localizedDescription
        case .outputStreamFileAlreadyExists:
            return "The file already exists at the URL"
        case .outputStreamURLInvalid:
            return "The OutputStream URL is invalid"
        case .outputStreamCreationFailed:
            return "Failed to create an OutputStream"
        case .outputStreamWriteFailed(let error):
            return "OutputStream write failed with error: \(error)"
        case .inputStreamReadFailed(let error):
            return "InputStream read failed with error: \(error)"
        case .noFileURL:
            return "File URL is absent"
        case .failedFileURLCasting:
            return "Failed file URL casting"
        case .unknown:
            return "Unknown error"
        }
    }
    
    private func handleDecodingError(_ error: DecodingError, url: URL?) -> String {
        var errorMessage = ""
        switch error {
        case .dataCorrupted(let context):
            errorMessage = "\(error.debugDescription)\n\(context.debugDescription)\n\(context.codingPath)"
        case let .keyNotFound(key, context):
            errorMessage = "\(error.debugDescription)\n\(key.description)\n\(context.debugDescription)\n\(context.codingPath)"
        case let .typeMismatch(type, context):
            errorMessage = "\(error.debugDescription)\n\(type)\n\(context.debugDescription)\n\(context.codingPath)"
        case let .valueNotFound(type, context):
            errorMessage = "\(error.debugDescription)\n\(type)\n\(context.debugDescription)\n\(context.codingPath)"
        @unknown default:
            errorMessage = "\(error.debugDescription)"
        }
        url.flatMap { errorMessage += "\nurl: \($0.absoluteString)" }
        return errorMessage
    }
}

extension NetworkError {
    public init(_ error: Error?) {
        switch error {
        case let apiError as APIError:
            self = .api(apiError)
        case let decodingError as DecodingError:
            self = .decoding(decodingError, nil)
        case .none:
            self = .unknown
        case .some(let error):
            if case .sessionTaskFailed = error as? NetworkError {
                self = .sessionTaskFailed(error)
            }
            self = .underlying(error)
        }
    }
}
