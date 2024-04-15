//
//  AnyEncodable.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 02.09.2022.
//

import Foundation

struct AnyEncodable: Encodable {
    let encodable: Encodable

    func encode(to encoder: Encoder) throws {
        try encodable.encode(to: encoder)
    }
}
