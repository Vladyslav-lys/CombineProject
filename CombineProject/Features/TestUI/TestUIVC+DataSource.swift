//
//  TestUIVC+DataSource.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 03.11.2022.
//

import UIKit
import Services

extension TestUIVC {
    typealias DataSource = UITableViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    enum Section: Int {
        case test
    }
    
    enum Item: Hashable {
        case test(test: Test, id: String)
    }
    
    func makeDataSource(for tableView: UITableView) -> DataSource {
        DataSource(tableView: tableView) { tableView, indexPath, item in
            switch item {
            case let .test(test,_):
                return tableView.makeCell(TestTVC.self, for: indexPath) {
                    $0.setup(test: test)
                }
            }
        }
    }
    
    func makeSnapshot(from tests: [Test]) -> Snapshot {
        with(NSDiffableDataSourceSnapshot<Section, Item>()) {
            if !tests.isEmpty {
                $0.appendSections([.test])
                $0.appendItems(makeItems(from: tests))
            }
        }
    }
    
    private func makeItems(from tests: [Test]) -> [Item] {
        tests.enumerated().map {
            .test(test: $0.element, id: $0.element.id)
        }
    }
}
