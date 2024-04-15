//
//  AppDelegate.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 29.08.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private lazy var platform = Platform()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let navigationController = UINavigationController(rootViewController: TestUIVC.make {
            $0.viewModel = TestUIVM()
        })
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        return platform.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
