//
//  Test.swift
//  Services
//
//  Created by Vladyslav Lysenko on 03.11.2022.
//

import Foundation

public struct Test: Equatable, Hashable {
    public let id = UUID().uuidString
    public let title: String
    public let imageUrl: String
    public let startTime: String
    public let endTime: String
    public let duration: String
    
    public init(title: String, imageUrl: String, startTime: String, endTime: String, duration: String) {
        self.title = title
        self.imageUrl = imageUrl
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
    }
}
