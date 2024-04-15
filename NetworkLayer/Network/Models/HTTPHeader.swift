//
//  HTTPHeader.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 30.08.2022.
//

import Foundation

public struct HTTPHeader: Hashable {
    public let name: String
    public let value: String
    
    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}

// MARK: - CustomStringConvertible
extension HTTPHeader: CustomStringConvertible {
    public var description: String {
        "\(name): \(value)"
    }
}

// MARK: - Header Objects
extension HTTPHeader {
    public static func accept(_ value: String) -> HTTPHeader {
        HTTPHeader(name: "Accept", value: value)
    }
    
    public static func acceptCharset(_ value: String) -> HTTPHeader {
        HTTPHeader(name: "Accept-Charset", value: value)
    }

    public static func acceptLanguage(_ value: String) -> HTTPHeader {
        HTTPHeader(name: "Accept-Language", value: value)
    }

    public static func acceptEncoding(_ value: String) -> HTTPHeader {
        HTTPHeader(name: "Accept-Encoding", value: value)
    }

    public static func authorization(username: String, password: String) -> HTTPHeader {
        let credential = Data("\(username):\(password)".utf8).base64EncodedString()
        return authorization("Basic \(credential)")
    }

    public static func authorization(bearerToken: String) -> HTTPHeader {
        authorization("Bearer \(bearerToken)")
    }

    public static func authorization(_ value: String) -> HTTPHeader {
        HTTPHeader(name: "Authorization", value: value)
    }
    public static func contentDisposition(_ value: String) -> HTTPHeader {
        HTTPHeader(name: "Content-Disposition", value: value)
    }

    public static func contentType(_ value: String) -> HTTPHeader {
        HTTPHeader(name: "Content-Type", value: value)
    }

    public static func userAgent(_ value: String) -> HTTPHeader {
        HTTPHeader(name: "User-Agent", value: value)
    }
}

// MARK: - Index
extension Array where Element == HTTPHeader {
    func index(of name: String) -> Int? {
        let lowercasedName = name.lowercased()
        return firstIndex { $0.name.lowercased() == lowercasedName }
    }
}

// MARK: - Default
extension HTTPHeader {
    public static let defaultAcceptEncoding: HTTPHeader = {
        let encodings: [String]
        if #available(iOS 11.0, macOS 10.13, tvOS 11.0, watchOS 4.0, *) {
            encodings = ["br", "gzip", "deflate"]
        } else {
            encodings = ["gzip", "deflate"]
        }

        return .acceptEncoding(encodings.qualityEncoded())
    }()

    public static let defaultAcceptLanguage: HTTPHeader = {
        .acceptLanguage(Locale.preferredLanguages.prefix(6).qualityEncoded())
    }()

    public static let defaultUserAgent: HTTPHeader = {
        let info = Bundle.main.infoDictionary
        let executable = (info?[kCFBundleExecutableKey as String] as? String) ??
            (ProcessInfo.processInfo.arguments.first?.split(separator: "/").last.map(String.init)) ??
            "Unknown"
        let bundle = info?[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
        let appVersion = info?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let appBuild = info?[kCFBundleVersionKey as String] as? String ?? "Unknown"

        let osNameVersion: String = {
            let version = ProcessInfo.processInfo.operatingSystemVersion
            let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
            let osName: String = {
                #if os(iOS)
                #if targetEnvironment(macCatalyst)
                return "macOS(Catalyst)"
                #else
                return "iOS"
                #endif
                #elseif os(watchOS)
                return "watchOS"
                #elseif os(tvOS)
                return "tvOS"
                #elseif os(macOS)
                return "macOS"
                #elseif os(Linux)
                return "Linux"
                #elseif os(Windows)
                return "Windows"
                #else
                return "Unknown"
                #endif
            }()

            return "\(osName) \(versionString)"
        }()

        let userAgent = "\(executable)/\(appVersion) (\(bundle); build:\(appBuild); \(osNameVersion))"

        return .userAgent(userAgent)
    }()
}

// MARK: - Qulity Encoded
extension Collection where Element == String {
    func qualityEncoded() -> String {
        enumerated().map { index, encoding in
            let quality = 1.0 - (Double(index) * 0.1)
            return "\(encoding);q=\(quality)"
        }.joined(separator: ", ")
    }
}
