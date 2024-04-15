//
//  Publishable.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 12.09.2022.
//

import Combine

protocol Publishable {
    associatedtype Publisher
    
    var publisher: Publisher? { get set }
    var cancellable: AnyCancellable? { get set }
    
    func didCreatePublisher(_ publisher: Publisher)
    func cancel() -> Self
    func resume() -> Self
}

extension Publishable {
    @discardableResult
    func cancel() -> Self {
        cancellable?.cancel()
        return self
    }
}
