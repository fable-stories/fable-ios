//
//  Character+Extension.swift
//  FableSDKModelObjects
//
//  Created by Andrew Aquino on 1/9/20.
//

import AppUIFoundation
import UIKit

extension Character {
  public var color: UIColor? {
    colorHexString.flatMap { UIColor($0) }
  }
}
