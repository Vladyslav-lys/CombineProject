//
//  TestUIVC.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 03.11.2022.
//

import UIKit

extension TestUIVC: Makeable {
    static func make() -> TestUIVC {
        UIStoryboard(name: "TestUI", bundle: nil).instantiateViewController(identifier: "TestUIVC") { coder in
            TestUIVC(coder: coder)
        }
    }
}

final class TestUIVC: BaseVC, ViewModelContainer {
    private enum StartTime: String {
        case earlist = "Earliest start time first"
        case latest = "Latest start time first"
    }
    
    @IBOutlet private weak var sortButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    
    var viewModel: TestUIVM?
    var selectedButtonItem: UIAction? {
        sortButton.menu?.children.first(where: { ($0 as? UIAction)?.state == .on }) as? UIAction
    }
    lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        return control
    }()
    
    private var dataSource: DataSource?
    
    // MARK: - Lifecyrcle
    init?(viewModel: TestUIVM, coder: NSCoder) {
        super.init(coder: coder)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
        getTestsAtStart()
    }
    
    private func setup() {
        dataSource = makeDataSource(for: tableView)
        withNonNil(tableView) {
            $0.register(TestTVC.self)
            $0.addSubview(refreshControl)
        }
        withNonNil(sortButton) { button in
            button.menu = UIMenu(children: [
                UIAction(title: StartTime.earlist.rawValue, state: .on, handler: handleMenuTap),
                UIAction(title: StartTime.latest.rawValue, handler: handleMenuTap)
            ])
            button.showsMenuAsPrimaryAction = true
        }
    }
    
    override func bind() {
        super.bind()
        viewModel?.$tests
            .compactMap { $0 }
            .sink { [weak self] in
                guard let self = self else { return }
                let snapshot = self.makeSnapshot(from: $0)
                self.dataSource?.apply(snapshot)
                self.refreshControl.endRefreshing()
            }
            .store(in: &subscriptions)
        setupViewModel()
    }
    
    private func getTestsAtStart() {
        isLoading = true
        getTests()
    }
    
    private func getTests() {
        viewModel?.getTests()
    }
    
    private func handleMenuTap(_ action: UIAction) {
        selectedButtonItem?.state = .off
        (sortButton.menu?.children.first(where: { $0 == action }) as? UIAction)?.state = .on
    }
    
    // MARK: - Actions
    @objc private func refresh(_ sender: AnyObject) {
        getTests()
    }
}
