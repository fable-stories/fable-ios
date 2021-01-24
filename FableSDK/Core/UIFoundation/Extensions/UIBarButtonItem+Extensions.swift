//
//  UIBarButtonItem+Extensions.swift
//  Fable
//
//  Created by Andrew Aquino on 10/16/19.
//

import AppFoundation
import UIKit

extension UIBarButtonItem {
  public static func makeCloseButton(onSelect: VoidClosure?) -> UIBarButtonItem {
    UIBarButtonItem(image: UIImage(named: "closeButton"), onSelect: onSelect)
  }

  public static func makeBackButton(onSelect: VoidClosure?) -> UIBarButtonItem {
    UIBarButtonItem(image: UIImage(named: "backIcon"), onSelect: onSelect)
  }

  public static func makeAddButton(onSelect: VoidClosure?) -> UIBarButtonItem {
    UIBarButtonItem(image: UIImage(named: "add_button_black"), onSelect: onSelect)
  }

  public static func makeDoneButton(onSelect: VoidClosure?) -> UIBarButtonItem {
    let button = UIBarButtonItem(title: "DONE", style: .done, target: nil, action: nil)
    button.setTitleTextAttributes([
      .font: UIFont.fableFont(11.0, weight: .bold),
      .foregroundColor: UIColor.fableBlack,
    ], for: .normal)
    button.setTitleTextAttributes([
      .font: UIFont.fableFont(11.0, weight: .bold),
      .foregroundColor: UIColor.fableDarkGray,
    ], for: .highlighted)
    if let onSelect = onSelect {
      button.reactive.pressed = .invoke(onSelect)
    }
    return button
  }
}
