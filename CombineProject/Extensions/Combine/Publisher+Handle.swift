//
//  Publisher+Handle.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 05.10.2022.
//

import Combine
import Services

extension Publisher where Failure == AppError {
    func attach<Root>(value: ReferenceWritableKeyPath<Root, Output?>? = nil,
                      error: ReferenceWritableKeyPath<Root, Error?>? = nil,
                      on object: Root) -> AnyCancellable {
        sink { completion in
            guard case .failure(let appError) = completion, let error = error else { return }
            object[keyPath: error] = appError
        } receiveValue: { output in
            guard let value = value else { return }
            object[keyPath: value] = output
        }
    }
}
