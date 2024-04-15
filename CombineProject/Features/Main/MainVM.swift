//
//  MainVM.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 04.10.2022.
//

import Combine
import Services
import WidgetKit

final class MainVM: BaseVM, UseCasesConsumer {
    typealias UseCases = HasUserUseCase & HasTransportUseCase
    
    @Published private(set) var users: [User]?
    @Published private(set) var uploadResult: Void?
    @Published private(set) var downloadResult: Void?
    
    private var progress: ((Double) -> Void)? = { progress in
        print(progress)
    }
    
    init(useCases: UseCases) {
        super.init()
        self.useCases = useCases
    }
    
    func getUsers(params: UserParams) {
        useCases.user
            .getUsers(params: params.parameters)
            .attach(value: \.users, error: \.error, on: self)
            .store(in: &subscriptions)
    }
    
    func upload(params: UploadFileParams) {
        useCases.user
            .upload(params: params.parameters, progress: progress)
            .attach(value: \.uploadResult, error: \.error, on: self)
            .store(in: &subscriptions)
    }
    
    func download() {
        useCases.user
            .download(progress: progress)
            .attach(value: \.downloadResult, error: \.error, on: self)
            .store(in: &subscriptions)
    }
    
    func setTextValue(_ value: String) {
        useCases.transport.setValue(value, forKey: .text)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func removeUser(_ user: User) {
        guard let index = users?.firstIndex(of: user) else { return }
        users?.remove(at: index)
    }
    
    func removeComment(_ comment: Comment, withUser user: User) {
        guard let userIndex = users?.firstIndex(of: user),
              let commentIndex = user.comments.firstIndex(of: comment) else { return }
        users?[userIndex].comments.remove(at: commentIndex)
    }
    
    func addComment(toUser user: User) {
        guard let userIndex = users?.firstIndex(of: user) else { return }
        users?[userIndex].comments.append(Comment(text: "comment"))
    }
}
