//
//  TransportUseCase.swift
//  Services
//
//  Created by Vladyslav Lysenko on 12.10.2022.
//

import Foundation

public enum TransportKeys: String {
    case text
}

public protocol TransportUseCase {
    func getValue(forKey key: TransportKeys) -> Any?
    func setValue(_ value: Any, forKey key: TransportKeys)
}
