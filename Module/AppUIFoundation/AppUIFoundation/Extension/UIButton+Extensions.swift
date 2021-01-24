//
//  UIButton+Extensions.swift
//  AppFoundation
//
//  Created by Andrew Aquino on 11/9/19.
//

import UIKit

extension UIButton {
  public func setImage(_ image: UIImage?, controlStateColors: [UIControl.State: UIColor]) {
    for (controlState, color) in controlStateColors {
      setImage(image?.tinted(color), for: controlState)
    }
  }
}

extension UIControl.State: Hashable {}
