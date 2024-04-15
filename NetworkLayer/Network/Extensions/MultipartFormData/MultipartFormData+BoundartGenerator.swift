//
//  MultipartFormData+BoundartGenerator.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 05.09.2022.
//

import Foundation

extension MultipartFormData {
    struct EncodingCharacters {
        static let crlf = "\r\n"
    }
    
    struct BoundaryGenerator {
        enum BoundaryType {
            case first, intermediated, last
        }

        static var randomBoundary: String {
            String(format: "boundary.%08x%08x", arc4random(), arc4random())
        }

        static func boundaryData(forBoundaryType boundaryType: BoundaryType, boundary: String) -> Data {
            let boundaryText: String

            switch boundaryType {
            case .first:
                boundaryText = "--\(boundary)\(EncodingCharacters.crlf)"
            case .intermediated:
                boundaryText = "\(EncodingCharacters.crlf)--\(boundary)\(EncodingCharacters.crlf)"
            case .last:
                boundaryText = "\(EncodingCharacters.crlf)--\(boundary)--\(EncodingCharacters.crlf)"
            }

            return Data(boundaryText.utf8)
        }
    }
}
