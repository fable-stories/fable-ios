//
//  UICollectionView+Extensions.swift
//  App
//
//  Created by Andrew Aquino on 4/13/19.
//

import UIKit

extension UICollectionViewCell {
  public static var reuseIdentifier: String {
    return String(describing: self)
  }
}

extension UICollectionView {
  public func dequeueReusableCell<T: UICollectionViewCell>(for registeredCell: T.Type, at indexPath: IndexPath) -> T {
    let reuseIdentifier = registeredCell.reuseIdentifier
    if let _ = objc_getAssociatedObject(0, reuseIdentifier),
      let cell = dequeueReusableCell(withReuseIdentifier: registeredCell.reuseIdentifier, for: indexPath) as? T {
      return cell
    }
    register(registeredCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    objc_setAssociatedObject(0, reuseIdentifier, 0, .OBJC_ASSOCIATION_ASSIGN)
    return self.dequeueReusableCell(for: registeredCell, at: indexPath)
  }
}
