//
//  ServiceContextProvider.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 04.10.2022.
//

import NetworkLayer

public final class ServiceContextProvider: ServiceContext {
    
    // MARK: - Properties
    public let network: Network
    
    // MARK: - Lifecycle
    public init(network: Network) {
        self.network = network
    }
}
