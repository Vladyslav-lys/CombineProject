//
//  Cancellable.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 30.08.2022.
//

import Foundation

protocol Cancellable {
    var isCancelled: Bool { get }
    func cancel()
}

final class CancellableToken: Cancellable {
    private let token: AtomicBool = false
    private var didCancelClosure: (() -> Void)?

    var isCancelled: Bool {
        token.value
    }

    func cancel() {
        token.value = true
        didCancelClosure?()
    }

    func didCancel(_ action: @escaping () -> Void) {
        didCancelClosure = action
    }
}
