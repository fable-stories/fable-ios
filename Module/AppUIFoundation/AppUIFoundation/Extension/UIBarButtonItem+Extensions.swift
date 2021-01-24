//
//  UIBarButtonItem+Extensions.swift
//  AppFoundation
//
//  Created by Andrew Aquino on 9/26/19.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import AppFoundation

extension UIBarButtonItem {
  public convenience init(image: UIImage?, onSelect: VoidClosure?) {
    self.init(image: image, style: .plain, target: nil, action: nil)
    self.image = image?.withRenderingMode(.alwaysOriginal)
    reactive.pressed = CocoaAction(Action<(), (), Never> {
      onSelect?()
      return .empty
    })
  }
}
