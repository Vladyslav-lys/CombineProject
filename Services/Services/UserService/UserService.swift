//
//  UserService.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 04.10.2022.
//

import NetworkLayer

public final class UserService {
    private let context: ServiceContext
    
    public init(context: ServiceContext) {
        self.context = context
    }
}

extension UserService: UserUseCase {
    public func getUsers(params: [String: Any]) -> AsyncTask<[User]> {
        context.network
            .request(API.Users.getUsers(params: params))
            .decode(APIResponse<[User.Response]>.self)
            .mapToAppError()
            .map { $0.results.map(User.init) }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    public func upload(params: [String: Any], progress: ((Double) -> Void)?) -> AsyncTask<Void> {
        context.network
            .request(API.Users.uplaod(params: params), progress: progress)
            .mapToAppError()
            .mapToVoid()
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    public func download(progress: ((Double) -> Void)?) -> AsyncTask<Void> {
        context.network
            .request(API.Users.download(destination: suggestedDownloadDestination(name: "image")),
                     progress: progress)
            .mapToAppError()
            .mapToVoid()
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    private func suggestedDownloadDestination(name: String,
                                              for directory: FileManager.SearchPathDirectory = .documentDirectory,
                                              in domain: FileManager.SearchPathDomainMask = .userDomainMask,
                                              options: Set<DownloadOptions> = [.removePreviousFile, .createIntermediateDirectories]) -> DownloadDestination {
        { temporaryURL, _ in
            let directoryURLs = FileManager.default.urls(for: directory, in: domain)
            let url = directoryURLs.first?.appendingPathComponent(name) ?? temporaryURL
            return (url, options)
        }
    }
}
