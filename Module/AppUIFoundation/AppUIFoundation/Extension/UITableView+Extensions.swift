//
//  UITableView+Extensions.swift
//  App
//
//  Created by Andrew Aquino on 4/13/19.
//

import UIKit

extension UITableViewCell {
  public static var reuseIdentifier: String {
    return String(describing: self)
  }
}

extension UITableView {
  public func dequeueReusableCell<T: UITableViewCell>(at indexPath: IndexPath) -> T! {
    let reuseIdentifier = T.reuseIdentifier
    guard let cell = dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? T else {
      return nil
    }
    return cell
  }
}

