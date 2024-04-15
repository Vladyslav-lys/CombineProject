//
//  TransportService.swift
//  Services
//
//  Created by Vladyslav Lysenko on 12.10.2022.
//

import Foundation

public final class TransportService {
    private let userDefaults = UserDefaults(suiteName: "group.com.cleveroad.CombineProject")
    
    public init() {}
}

extension TransportService: TransportUseCase {
    public func getValue(forKey key: TransportKeys) -> Any? {
        userDefaults?.value(forKey: key.rawValue)
    }
    
    public func setValue(_ value: Any, forKey key: TransportKeys) {
        userDefaults?.set(value, forKey: key.rawValue)
    }
}
