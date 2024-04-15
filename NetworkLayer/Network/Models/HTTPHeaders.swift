//
//  HTTPHeaders.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 30.08.2022.
//

import Foundation

public struct HTTPHeaders {
    private var headers: [HTTPHeader] = []

    public init() {}

    public init(_ headers: [HTTPHeader]) {
        self.init()
        headers.forEach { update($0) }
    }

    public init(_ dictionary: [String: String]) {
        self.init()
        dictionary.forEach { update(HTTPHeader(name: $0.key, value: $0.value)) }
    }

    public mutating func add(name: String, value: String) {
        update(HTTPHeader(name: name, value: value))
    }

    public mutating func add(_ header: HTTPHeader) {
        update(header)
    }

    public mutating func update(name: String, value: String) {
        update(HTTPHeader(name: name, value: value))
    }

    public mutating func update(_ header: HTTPHeader) {
        guard let index = headers.index(of: header.name) else {
            headers.append(header)
            return
        }
        headers.replaceSubrange(index...index, with: [header])
    }

    public mutating func remove(name: String) {
        guard let index = headers.index(of: name) else { return }
        headers.remove(at: index)
    }

    public mutating func sort() {
        headers.sort { $0.name.lowercased() < $1.name.lowercased() }
    }

    public func sorted() -> HTTPHeaders {
        var headers = self
        headers.sort()
        return headers
    }

    public func value(for name: String) -> String? {
        guard let index = headers.index(of: name) else { return nil }

        return headers[index].value
    }

    public subscript(_ name: String) -> String? {
        get { value(for: name) }
        set {
            if let value = newValue {
                update(name: name, value: value)
            } else {
                remove(name: name)
            }
        }
    }

    public var dictionary: [String: String] {
        let namesAndValues = headers.map { ($0.name, $0.value) }
        return Dictionary(namesAndValues, uniquingKeysWith: { _, last in last })
    }
}

// MARK: - ExpressibleByDictionaryLiteral
extension HTTPHeaders: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, String)...) {
        self.init()
        elements.forEach { update(name: $0.0, value: $0.1) }
    }
}

// MARK: - ExpressibleByArrayLiteral
extension HTTPHeaders: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: HTTPHeader...) {
        self.init(elements)
    }
}

// MARK: - Sequence
extension HTTPHeaders: Sequence {
    public func makeIterator() -> IndexingIterator<[HTTPHeader]> {
        headers.makeIterator()
    }
}

// MARK: - Sequence
extension HTTPHeaders: Collection {
    public var startIndex: Int {
        headers.startIndex
    }

    public var endIndex: Int {
        headers.endIndex
    }

    public subscript(position: Int) -> HTTPHeader {
        headers[position]
    }

    public func index(after i: Int) -> Int {
        headers.index(after: i)
    }
}

// MARK: - CustomStringConvertible
extension HTTPHeaders: CustomStringConvertible {
    public var description: String {
        headers.map { $0.description }.joined(separator: "\n")
    }
}

// MARK: - Default
extension HTTPHeaders {
    public static let `default`: HTTPHeaders = [.defaultAcceptEncoding,
                                                .defaultAcceptLanguage,
                                                .defaultAccept,
                                                .defaultUserAgent]
}

// MARK: - System Type Extensions
extension URLRequest {
    public var headers: HTTPHeaders {
        get { allHTTPHeaderFields.map(HTTPHeaders.init) ?? HTTPHeaders() }
        set { allHTTPHeaderFields = newValue.dictionary }
    }
}

extension HTTPURLResponse {
    public var headers: HTTPHeaders {
        (allHeaderFields as? [String: String]).map(HTTPHeaders.init) ?? HTTPHeaders()
    }
}

extension URLSessionConfiguration {
    public var headers: HTTPHeaders {
        get { (httpAdditionalHeaders as? [String: String]).map(HTTPHeaders.init) ?? HTTPHeaders() }
        set { httpAdditionalHeaders = newValue.dictionary }
    }
}
