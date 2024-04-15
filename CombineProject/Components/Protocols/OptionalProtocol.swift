//
//  OptionalProtocol.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 19.10.2022.
//

import Foundation

public protocol OptionalProtocol {
    associatedtype Wrapped

    init(reconstructing value: Wrapped?)

    var optional: Wrapped? { get }
}

extension Optional: OptionalProtocol {
    public var optional: Wrapped? {
        self
    }

    public init(reconstructing value: Wrapped?) {
        self = value
    }
}
