//
//  NSMutableParagraphStyle+.swift
//  AppUIFoundation
//
//  Created by Andrew Aquino on 12/27/20.
//

import Foundation
import UIKit

public extension NSMutableParagraphStyle {
  convenience init(alignment: NSTextAlignment? = nil) {
    self.init()
    alignment.flatMap { self.alignment = $0 }
  }
}
