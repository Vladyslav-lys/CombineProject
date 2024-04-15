//
//  UserParams.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 06.10.2022.
//

import Foundation

public struct UserParams {
    enum CodingKeys: String, CodingKey {
        case results
    }
    
    public let results: Int
    
    public init(results: Int) {
        self.results = results
    }
    
    public var parameters: [String: Any] {
        [CodingKeys.results.rawValue: results]
    }
}
