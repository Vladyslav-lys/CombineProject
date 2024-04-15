//
//  With.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 19.10.2022.
//

import Foundation

@discardableResult
func with<T>(_ value: T, _ builder: (inout T) throws -> Void) rethrows -> T {
    var mutableValue = value
    try builder(&mutableValue)
    return mutableValue
}

@discardableResult
func withNonNil<T: OptionalProtocol>(_ value: T, _ builder: (inout T.Wrapped) throws -> Void) rethrows -> T {
    if var mutableValue = value.optional {
        try builder(&mutableValue)
        return T(reconstructing: mutableValue)
    } else {
        return value
    }
}
