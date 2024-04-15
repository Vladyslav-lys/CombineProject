//
//  DetailVM.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 21.10.2022.
//

import Services

final class DetailVM: BaseVM {
    @Published private(set) var user: User?
    
    init(user: User) {
        self.user = user
    }
}
