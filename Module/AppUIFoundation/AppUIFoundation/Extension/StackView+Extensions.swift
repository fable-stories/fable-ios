//
//  StackView+Extensions.swift
//  AppFoundation
//
//  Created by Andrew Aquino on 11/19/19.
//

import UIKit

extension UIStackView {
  public func addArrangedSubviews(_ views: [UIView]) {
    views.forEach { addArrangedSubview($0) }
  }
}
