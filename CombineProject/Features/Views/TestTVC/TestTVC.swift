//
//  TestTVC.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 03.11.2022.
//

import UIKit
import Services

final class TestTVC: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var startLabel: UILabel!
    @IBOutlet private weak var endLabel: UILabel!
    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet private weak var currentImageView: UIImageView!
    
    func setup(test: Test) {
        titleLabel.text = test.title
        startLabel.text = test.startTime
        endLabel.text = test.endTime
        durationLabel.text = test.duration
        getData(from: URL(string: test.imageUrl))
    }
    
    private func getData(from url: URL?) {
        guard let url = url else { return }
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.currentImageView.image = image
                    }
                }
            }
        }
    }
}
