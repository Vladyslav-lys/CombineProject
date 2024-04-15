//
//  Makeble.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 04.10.2022.
//

import Foundation

protocol Makeable {
    associatedtype Value = Self
    typealias Builder = (inout Value) -> Void
    static func make() -> Value
}

extension Makeable {
    static func make(_ builder: Builder) -> Value {
        var product = make()
        builder(&product)
        return product
    }
}
