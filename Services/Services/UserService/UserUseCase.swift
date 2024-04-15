//
//  UserUseCase.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 04.10.2022.
//

import Foundation

public protocol UserUseCase {
    func getUsers(params: [String: Any]) -> AsyncTask<[User]>
    func upload(params: [String: Any], progress: ((Double) -> Void)?) -> AsyncTask<Void>
    func download(progress: ((Double) -> Void)?) -> AsyncTask<Void>
}
