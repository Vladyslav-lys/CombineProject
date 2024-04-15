//
//  BaseVC.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 05.10.2022.
//

import UIKit
import Combine

class BaseVC: UIViewController {
    private enum C {
        static let activityAnimationDuration: TimeInterval = 0.25
        static let activityGraceTime: TimeInterval = 0.1
    }
    
    @Published var isLoading = false
    var subscriptions: Set<AnyCancellable> = []
    
    private lazy var activityView = makeActivityView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    func bind() {
        $isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isExecuting in
                isExecuting ? self?.showActivity() : self?.hideActivity()
            }
            .store(in: &subscriptions)
    }
    
    func showActivity(animated: Bool = true) {
        let duration: TimeInterval = animated ? C.activityAnimationDuration : 0
        let delay: TimeInterval = animated ? C.activityGraceTime : 0
        UIView.animate(withDuration: duration, delay: delay, options: .beginFromCurrentState) {
            self.activityView.alpha = 1.0
            self.activityView.isAnimating = true
        }
    }
    
    func hideActivity(animated: Bool = true) {
        let duration: TimeInterval = animated ? C.activityAnimationDuration : 0
        UIView.animate(withDuration: duration, delay: 0.0, options: .beginFromCurrentState) {
            self.activityView.alpha = 0.0
        }
    }
    
    private func makeActivityView() -> ActivityView {
        let activity = ActivityView(frame: view.bounds)
        activity.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        activity.alpha = 0
        view.addSubview(activity)
        return activity
    }
}
