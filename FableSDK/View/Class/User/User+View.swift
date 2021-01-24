//
//  User+View.swift
//  FableSDKViews
//
//  Created by Andrew Aquino on 12/26/20.
//

import Foundation
import FableSDKModelObjects

public extension User {
  var displayName: String  {
    if let userName = userName {
      return userName
    }
    return ""
  }
}
