//
//  MultipartFormData+BodyPart.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 05.09.2022.
//

import Foundation

extension MultipartFormData {
    class BodyPart {
        let headers: HTTPHeaders
        let bodyStream: InputStream
        let bodyContentLength: UInt64
        var isFirstBoundary = false
        var isLastBoundary = false

        init(headers: HTTPHeaders, bodyStream: InputStream, bodyContentLength: UInt64) {
            self.headers = headers
            self.bodyStream = bodyStream
            self.bodyContentLength = bodyContentLength
        }
    }
}

extension Array where Element == MultipartFormData.BodyPart {
    func turnOnFirstAndLastBoundary() {
        first?.isFirstBoundary = true
        last?.isLastBoundary = true
    }
}
