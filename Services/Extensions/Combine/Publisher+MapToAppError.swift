//
//  Publisher+MapToAppError.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 04.10.2022.
//

import NetworkLayer
import Combine

extension AnyPublisher where Failure == NetworkError {
    func mapToAppError() -> AnyPublisher<Output, AppError> {
        mapError(AppError.network).eraseToAnyPublisher()
    }
}
