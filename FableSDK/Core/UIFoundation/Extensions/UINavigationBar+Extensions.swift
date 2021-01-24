//
//  UINavigationBar+Extensions.swift
//  Fable
//
//  Created by Andrew Aquino on 9/26/19.
//

import AppFoundation
import UIKit

extension UINavigationBar {
  public static func titleAttributes() -> [NSAttributedString.Key: Any] {
    let pStyle = NSMutableParagraphStyle()
    pStyle.alignment = .center
    return [
      .foregroundColor: UIColor.fableBlack,
      .font: UIFont.fableFont(13.0, weight: .bold),
      .paragraphStyle: pStyle,
    ]
  }
}
