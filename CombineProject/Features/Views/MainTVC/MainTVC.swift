//
//  MainTVC.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 19.10.2022.
//

import UIKit
import Services

protocol MainTVCDelegate: AnyObject {
    func didTapRemove(_ cell: MainTVC, with user: User)
    func didTapRemoveComment(_ cell: MainTVC, with comment: Comment, andUser user: User)
    func didTapAddComment(_ cell: MainTVC, withUser user: User)
    func didGetPreview(_ cell: MainTVC, withUser user: User) -> UIViewController
}

final class MainTVC: UITableViewCell {
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var commentStackView: UIStackView!
    
    private weak var delegate: MainTVCDelegate?
    private var user: User?
    
    func setup(user: User, delegate: MainTVCDelegate) {
        commentStackView.subviews.forEach { $0.removeFromSuperview() }
        label.text = "\(user.name.first) \(user.name.last)"
        self.user = user
        self.delegate = delegate
        
        let contextMenuInteraction = UIContextMenuInteraction(delegate: self)
        addInteraction(contextMenuInteraction)
        
        if !user.comments.isEmpty {
            user.comments.forEach {
                let commentView = CommentView.make()
                commentView.setup(comment: $0, delegate: self)
                commentStackView.addArrangedSubview(commentView)
            }
        }
    }
}

// MARK: - UIContextMenuInteractionDelegate
extension MainTVC: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: nil, previewProvider: { [weak self] () -> UIViewController? in
            guard let self = self, let user = self.user else { return nil }
            return self.delegate?.didGetPreview(self, withUser: user)
        }) { _ in
            let remove = UIAction(title: "Remove",
                                  image: UIImage(systemName: "trash"),
                                  attributes: .destructive) { [weak self] _ in
                guard let self = self, let user = self.user else { return }
                self.delegate?.didTapRemove(self, with: user)
            }
            let addComment = UIAction(title: "Add Comment") { [weak self] _ in
                guard let self = self, let user = self.user  else { return }
                self.delegate?.didTapAddComment(self, withUser: user)
            }
            return UIMenu(title: "User Menu", children: [addComment, remove])
        }
    }
}

// MARK: - CommentViewDelegate
extension MainTVC: CommentViewDelegate {
    func didTapRemove(_ view: CommentView, with comment: Comment) {
        guard let user = user else { return }
        delegate?.didTapRemoveComment(self, with: comment, andUser: user)
    }
}
