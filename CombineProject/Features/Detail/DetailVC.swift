//
//  DetailVC.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 21.10.2022.
//

import UIKit

extension DetailVC: Makeable {
    static func make() -> DetailVC {
        UIStoryboard(name: "Detail", bundle: nil).instantiateViewController(identifier: "DetailVC") { coder in
            DetailVC(coder: coder)
        }
    }
}

final class DetailVC: BaseVC, ViewModelContainer {
    @IBOutlet private weak var label: UILabel!
    
    var viewModel: DetailVM?
    
    // MARK: - Lifecyrcle
    init?(viewModel: DetailVM, coder: NSCoder) {
        super.init(coder: coder)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    // MARK: - Bind
    override func bind() {
        super.bind()
        viewModel?.$user
            .compactMap { $0 }
            .sink { [weak self] in
                guard let self = self else { return }
                self.label.text = "\($0.name.first) \($0.name.last)"
            }
            .store(in: &subscriptions)
        
        viewModel?.$error
            .compactMap { $0 }
            .sink {
                print($0.localizedDescription)
            }
            .store(in: &subscriptions)
    }
}
