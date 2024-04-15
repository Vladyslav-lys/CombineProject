//
//  Platform.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 29.08.2022.
//

import UIKit
import Services
import NetworkLayer

final class Platform: UseCaseProvider {
    
    // MARK: - UseCases
    var user: UserUseCase
    var transport: TransportUseCase
    
    // MARK: - Private properties
    private let network: Network
    private let environment: SwiftConfiguration
    private let authPlugin = AuthorizationPlugin()
    
    init() {
        environment = SwiftConfiguration.current
        network = Network(baseURL: URL(string: environment.baseUrl)!,
                          plugins: [APIErrorPlugin()])
        
        let context = ServiceContextProvider(network: network)
        user = UserService(context: context)
        transport = TransportService()
    }
    
    // MARK: - AppDelegate
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        true
    }
}
