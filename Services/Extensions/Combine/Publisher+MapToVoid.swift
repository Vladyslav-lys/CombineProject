//
//  Publisher+MapToVoid.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 06.10.2022.
//

import Combine

extension Publisher {
    func mapToVoid() -> AnyPublisher<Void, Failure> {
        map { _ in () }
            .eraseToAnyPublisher()
    }
}
