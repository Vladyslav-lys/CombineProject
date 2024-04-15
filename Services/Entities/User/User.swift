//
//  User.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 04.10.2022.
//

import Foundation

public typealias Comment = User.Comment

public struct User: Equatable, Hashable {
    public let name: Name
    public let gender: String
    public let email: String
    public var comments: [Comment]
}

public extension User {
    struct Name: Equatable, Hashable, Decodable {
        public let title: String
        public let first: String
        public let last: String
    }
}

public extension User {
    struct Comment: Equatable, Hashable {
        public let id = UUID()
        public let text: String
        
        public init(text: String) {
            self.text = text
        }
    }
}
