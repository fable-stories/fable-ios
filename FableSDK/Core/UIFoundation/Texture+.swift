//
//  Texture+.swift
//  FableSDKUIFoundation
//
//  Created by Andrew Aquino on 11/28/20.
//

import Foundation
import AsyncDisplayKit

public extension ASDisplayNode {
  static func new<T>(_ closure: () -> T) -> T {
    return closure()
  }
}
