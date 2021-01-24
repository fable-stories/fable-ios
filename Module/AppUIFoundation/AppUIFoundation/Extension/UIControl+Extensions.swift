//
//  UIControl+Extensions.swift
//  AppFoundation
//
//  Created by Andrew Aquino on 11/10/19.
//

import UIKit

extension UIControl.State: CustomStringConvertible {
  public var description: String {
    switch self {
    case .normal: return "normal"
    case .highlighted: return "highlighted"
    case .focused: return "focused"
    case .selected: return "selected"
    case .disabled: return "disabled"
    case .reserved: return "reserved"
    case .application: return "application"
    default: return String(describing: self.rawValue)
    }
  }
}
