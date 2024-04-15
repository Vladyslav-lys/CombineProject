//
//  APIResponse.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 30.08.2022.
//

import Foundation

public struct APIPageResponse<Value> {
    public let data: Value
    public let pagination: LimitOffset.Response
    
    public init(data: Value, pagination: LimitOffset.Response) {
        self.data = data
        self.pagination = pagination
    }

    func map<T>(_ transform: (Value) throws -> T) rethrows -> APIPageResponse<T> {
        let newData = try transform(data)
        return APIPageResponse<T>(data: newData, pagination: pagination)
    }
}

extension APIPageResponse: Decodable where Value: Decodable {}

public struct APIResponse<Value> {
    public let results: Value

    func map<T>(_ transform: (Value) throws -> T) rethrows -> APIResponse<T> {
        let newData = try transform(results)
        return APIResponse<T>(results: newData)
    }
}

extension APIResponse: Decodable where Value: Decodable { }
