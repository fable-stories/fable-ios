//
//  UICollectionView+Extensions.swift
//  AppFoundation
//
//  Created by Madan on 06/08/20.
//

import AppFoundation
import Foundation
import UIKit

extension UICollectionViewCell {
  public static var reuseIdentifier: String {
    return String(describing: self)
  }
}

extension UICollectionView {
  public func dequeueReusableCell<T: UICollectionViewCell>(at indexPath: IndexPath) -> T! {
    let reuseIdentifier = T.reuseIdentifier
    register(T.self, forCellWithReuseIdentifier: reuseIdentifier)
    guard let cell = dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? T else {
      return nil
    }
    return cell
  }
}
