//
//  BaseVM.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 04.10.2022.
//

import Combine

class BaseVM {
    @Published var isLoading = false
    @Published var error: Error?
    var subscriptions: Set<AnyCancellable> = []
    
    deinit {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
    }
}
