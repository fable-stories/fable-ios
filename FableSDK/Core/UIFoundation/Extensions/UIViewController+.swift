//
//  UIViewController+.swift
//  FableSDKUIFoundation
//
//  Created by Andrew Aquino on 7/5/20.
//

import AppFoundation
import Foundation
import UIKit

public extension UIViewController {
  func wrapInNavigationController(onClose: @escaping VoidClosure) -> UINavigationController {
    navigationItem.leftBarButtonItem = .makeCloseButton(onSelect: onClose)
    return UINavigationController(rootViewController: self)
  }
}
