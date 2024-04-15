//
//  MultipartFormData.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 30.08.2022.
//

import UniformTypeIdentifiers

public class MultipartFormData {

    // MARK: - Properties
    lazy var contentType = "multipart/form-data; boundary=\(boundary)"
    var contentLength: UInt64 {
        bodyParts.reduce(0) { $0 + $1.bodyContentLength }
    }
    
    private let boundary: String
    private var bodyParts: [BodyPart]
    private let streamBufferSize: Int
    
    private var firstBoundaryData: Data {
        BoundaryGenerator.boundaryData(forBoundaryType: .first, boundary: boundary)
    }

    private var intermediatedBoundaryData: Data {
        BoundaryGenerator.boundaryData(forBoundaryType: .intermediated, boundary: boundary)
    }

    private var lastBoundaryData: Data {
        BoundaryGenerator.boundaryData(forBoundaryType: .last, boundary: boundary)
    }

    // MARK: - Lifecycle
    public init(boundary: String? = nil) {
        self.boundary = boundary ?? BoundaryGenerator.randomBoundary
        bodyParts = []
        streamBufferSize = 1024
    }

    // MARK: - Body Parts
    public func append(_ data: Data, withName name: String, fileName: String? = nil, mimeType: String? = nil) {
        var disposition = "form-data; name=\"\(name)\""
        
        if let fileName = fileName {
            disposition += "; filename=\"\(fileName)\""
        }

        var headers: HTTPHeaders = [.contentDisposition(disposition)]
        
        if let mimeType = mimeType {
            headers.add(.contentType(mimeType))
        }
        
        let stream = InputStream(data: data)
        let length = UInt64(data.count)

        let bodyPart = BodyPart(headers: headers, bodyStream: stream, bodyContentLength: length)
        bodyParts.append(bodyPart)
    }

    // MARK: - Encoding
    public func encode() throws -> Data {
        var encoded = Data()

        bodyParts.turnOnFirstAndLastBoundary()
        try bodyParts.forEach {
            let encodedData = try encode($0)
            encoded.append(encodedData)
        }

        return encoded
    }

    // MARK: - Private - Body Part Encoding
    private func encode(_ bodyPart: BodyPart) throws -> Data {
        var encoded = Data()

        let initialData = bodyPart.isFirstBoundary ? firstBoundaryData : intermediatedBoundaryData
        encoded.append(initialData)

        let headerData = encodeHeaders(for: bodyPart)
        encoded.append(headerData)

        let bodyStreamData = try encodeBodyStream(for: bodyPart)
        encoded.append(bodyStreamData)

        if bodyPart.isLastBoundary {
            encoded.append(lastBoundaryData)
        }

        return encoded
    }

    private func encodeHeaders(for bodyPart: BodyPart) -> Data {
        let headerText = bodyPart.headers.map { "\($0.name): \($0.value)\(EncodingCharacters.crlf)" }
            .joined()
            + EncodingCharacters.crlf

        return Data(headerText.utf8)
    }

    private func encodeBodyStream(for bodyPart: BodyPart) throws -> Data {
        let inputStream = bodyPart.bodyStream
        inputStream.open()
        defer { inputStream.close() }

        var encoded = Data()

        while inputStream.hasBytesAvailable {
            var buffer = [UInt8](repeating: 0, count: streamBufferSize)
            let bytesRead = inputStream.read(&buffer, maxLength: streamBufferSize)

            if let error = inputStream.streamError {
                throw NetworkError.inputStreamReadFailed(error)
            }

            if bytesRead > 0 {
                encoded.append(buffer, count: bytesRead)
            } else {
                break
            }
        }

        return encoded
    }
}
