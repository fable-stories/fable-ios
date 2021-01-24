//
//  UIView+Extensions.swift
//  AppFoundation
//
//  Created by Edmund Ng on 2020-06-10.
//

import UIKit

extension UIView {
  public func addSubViews(_ views: UIView...) {
    for view in views {
      addSubview(view)
    }
  }
}
