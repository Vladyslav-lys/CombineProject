//
//  ViewModelContainer.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 04.10.2022.
//

import Foundation

protocol ViewModelContainer: AnyObject {
    associatedtype ViewModel: BaseVM
    
    var viewModel: ViewModel? { get set }
    func bind()
}

extension ViewModelContainer where Self: BaseVC {
    func setupViewModel() {
        viewModel?.$isLoading
            .assign(to: \.isLoading, on: self)
            .store(in: &subscriptions)
    }
}
