//
//  UIResponder+Extensions.swift
//  AppFoundation
//
//  Created by Andrew Aquino on 10/4/19.
//

import UIKit
import ReactiveSwift

extension UIResponder {
  public class GlobalRef {
    public static func mutableFirstResponder() -> MutableProperty<UIResponder?> {
      let identifier = "UITextField.GlobalRef.mutableFirstResponder"
      if let object = objc_getAssociatedObject(0, identifier) as? MutableProperty<UIResponder?> {
        return object
      }
      let mutableProperty = MutableProperty<UIResponder?>(nil)
      objc_setAssociatedObject(mutableProperty, identifier, 0, .OBJC_ASSOCIATION_ASSIGN)
      return mutableProperty
    }
  }
}
