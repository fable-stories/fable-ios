//
//  UINavigationItem+Extensions.swift
//  Fable
//
//  Created by Andrew Aquino on 11/19/19.
//

import AppFoundation
import UIKit

extension UINavigationItem {
  public static func makeTitleView(_ title: String, subtitle: String = "") -> UIView {
    makeTitleView(title, attributes: [
      .foregroundColor: UIColor.fableBlack,
      .font: UIFont.fableFont(13.0, weight: .bold),
    ])
  }
}
