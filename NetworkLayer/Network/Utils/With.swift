//
//  With.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 30.08.2022.
//

import Foundation

@discardableResult
public func with<T>(_ value: T,
                    _ builder: (inout T) throws -> Void) rethrows -> T {
    var mutableValue = value
    try builder(&mutableValue)
    return mutableValue
}
