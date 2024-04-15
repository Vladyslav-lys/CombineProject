//
//  MainVC+Datasource.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 19.10.2022.
//

import UIKit
import Services

extension MainVC {
    typealias DataSource = UITableViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    enum Section: Int {
        case main
    }
    
    enum Item: Hashable {
        case main(user: User, email: String)
    }
    
    func makeDataSource(for tableView: UITableView) -> DataSource {
        DataSource(tableView: tableView) { tableView, indexPath, item in
            switch item {
            case let .main(user,_):
                return tableView.makeCell(MainTVC.self, for: indexPath) {
                    $0.setup(user: user, delegate: self)
                }
            }
        }
    }
    
    func makeSnapshot(from users: [User]) -> Snapshot {
        with(NSDiffableDataSourceSnapshot<Section, Item>()) {
            if !users.isEmpty {
                $0.appendSections([.main])
                $0.appendItems(makeItems(from: users))
            }
        }
    }
    
    private func makeItems(from users: [User]) -> [Item] {
        users.enumerated().map {
            .main(user: $0.element, email: $0.element.email)
        }
    }
}
