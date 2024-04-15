//
//  CommentView.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 20.10.2022.
//

import UIKit
import Services

protocol CommentViewDelegate: AnyObject {
    func didTapRemove(_ view: CommentView, with comment: Comment)
}

final class CommentView: UIView {
    @IBOutlet private weak var label: UILabel!
    
    private weak var delegate: CommentViewDelegate?
    private var comment: Comment?
    
    func setup(comment: Comment, delegate: CommentViewDelegate) {
        label.text = comment.text
        self.comment = comment
        self.delegate = delegate
        
        let contextMenuInteraction = UIContextMenuInteraction(delegate: self)
        addInteraction(contextMenuInteraction)
    }
}

// MARK: - UIContextMenuInteractionDelegate
extension CommentView: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let remove = UIAction(title: "Remove",
                                  image: UIImage(systemName: "trash"),
                                  attributes: .destructive) { [weak self] _ in
                guard let self = self, let comment = self.comment else { return }
                self.delegate?.didTapRemove(self, with: comment)
            }
            return UIMenu(title: "User Menu", children: [remove])
        }
    }
}

// MARK: - Makeable
extension CommentView: Makeable {
    static func make() -> CommentView {
        let bundleName = Bundle(for: CommentView.self)
        let nibName = String(describing: CommentView.self)
        let nib = UINib(nibName: nibName, bundle: bundleName)
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? CommentView else {
            return .init()
        }
        return view
    }
}
