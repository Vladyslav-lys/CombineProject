//
//  Command.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 08.09.2022.
//

import Foundation

struct Command<Value> {
    typealias Action = (Value) -> Void
    private let action: Action

    init(_ action: @escaping Action) {
        self.action = action
    }

    func perform(value: Value,
                 file: String = #file,
                 function: String = #function,
                 line: Int = #line) {
        action(value)
    }
}

extension Command where Value == Void {
    func perform(file: String = #file,
                 function: String = #function,
                 line: Int = #line) {
        perform(value: ())
    }
}
