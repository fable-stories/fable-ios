//
//  BarButtonItem.swift
//  AppUIFoundation
//
//  Created by Andrew Aquino on 7/26/19.
//

import UIKit
import ReactiveSwift
import ReactiveFoundation
import AppFoundation

public class BarButtonItem: UIBarButtonItem {
  
  public init(image: UIImage?, onTap: VoidClosure? = nil) {
    super.init()
    self.image = image?.withRenderingMode(.alwaysOriginal)
    if let onTap = onTap { reactive.pressed = .invoke(onTap) }
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError()
  }
}
