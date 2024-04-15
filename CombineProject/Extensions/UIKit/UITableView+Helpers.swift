//
//  UITableView+Helpers.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 19.10.2022.
//

import UIKit

extension UITableView {
    
    func register(_ types: UITableViewCell.Type...) {
        types.forEach(registerNib)
    }
    
    func registerNib<T>(for cellClass: T.Type) where T: UITableViewCell {
      let identifier = String(describing: cellClass)
      register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
    }
     
    func dequeueReusableCell<T: UITableViewCell>(cellClass: T.Type, for indexPath: IndexPath) -> T {
      guard let cell = dequeueReusableCell(withIdentifier: String(describing: cellClass), for: indexPath) as? T else {
        fatalError("Cannot find cell \(String(describing: cellClass))")
      }
      return cell
    }
     
    func dequeueReusableCell<T: UITableViewCell>(cellClass: T.Type) -> T {
      guard let cell = dequeueReusableCell(withIdentifier: String(describing: cellClass)) as? T else {
        fatalError("Cannot find cell \(String(describing: cellClass))")
      }
      return cell
    }
     
    func dequeueReusableFooter<T: UIView>(cellClass: T.Type) -> T {
      guard let cell = dequeueReusableCell(withIdentifier: String(describing: cellClass)) as? T else {
        fatalError("Cannot find cell \(String(describing: cellClass))")
      }
      return cell
    }
     
    func dequeueReusableHeader<T: UIView>(cellClass: T.Type) -> T {
      guard let cell = dequeueReusableCell(withIdentifier: String(describing: cellClass)) as? T else {
        fatalError("Cannot find cell \(String(describing: cellClass))")
      }
      return cell
    }
     
    func makeCell<T: UITableViewCell>(at indexPath: IndexPath, builder: (T) -> Void) -> T {
      let cell = dequeueReusableCell(cellClass: T.self, for: indexPath)
      builder(cell)
      return cell
    }
    
    func makeCell<T: UITableViewCell>(_ cellClass: T.Type, for indexPath: IndexPath, builder: (T) -> Void = { _ in }) -> T {
        with(dequeueReusableCell(cellClass: cellClass, for: indexPath)) {
            builder($0)
        }
    }
    
    func insertSectionAndScroll(to index: Int) {
        performBatchUpdates({
            UIView.performWithoutAnimation {
                insertSections(IndexSet(integer: index), with: .automatic)
            }
        }, completion: { [weak self] _ in
            self?.scrollToRow(at: IndexPath(row: NSNotFound, section: index), at: .top, animated: true)
        })
    }
}
