//
//  UseCaseProvider.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 29.08.2022.
//

import Foundation

public protocol HasUserUseCase {
    var user: UserUseCase { get set }
}

public protocol HasTransportUseCase {
    var transport: TransportUseCase { get set }
}

public typealias UseCases = HasUserUseCase & HasTransportUseCase

public protocol UseCaseProvider: UseCases {}
