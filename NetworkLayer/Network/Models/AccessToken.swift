//
//  AccessToken.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 30.08.2022.
//

import Foundation

public final class AccessToken: Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case tokenString = "access_token"
        case refreshTokenString = "refresh_token"
        case expirationDate = "expires_in"
    }

    let tokenString: String
    public let refreshTokenString: String?
    private var expirationDate: Date

    var isValid: Bool {
        expirationDate > Date()
    }

    func invalidate() {
        expirationDate = Date()
    }
    
    public init(token: String, refreshToken: String, expirationDate: Date) {
        tokenString = token
        refreshTokenString = refreshToken
        self.expirationDate = expirationDate
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        tokenString = try container.decode(String.self, forKey: .tokenString)
        refreshTokenString = try container.decodeIfPresent(String.self, forKey: .refreshTokenString)
        
        let seconds = try container.decode(Int.self, forKey: .expirationDate)
        expirationDate = Date(timeInterval: TimeInterval(seconds), since: Date())
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tokenString, forKey: .tokenString)
        try container.encode(refreshTokenString, forKey: .refreshTokenString)
        
        let interval = expirationDate.timeIntervalSince(Date())
        let seconds = Int(interval)
        try container.encode(seconds, forKey: .expirationDate)
    }
    
    public static func == (lhs: AccessToken, rhs: AccessToken) -> Bool {
        lhs.tokenString == rhs.tokenString && lhs.refreshTokenString == rhs.refreshTokenString && lhs.expirationDate == rhs.expirationDate
    }
}

extension AccessToken {
    var authorizationHeader: HTTPHeader {
        .authorization("Bearer \(tokenString)")
    }
}
