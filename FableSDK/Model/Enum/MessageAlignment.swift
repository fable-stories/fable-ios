//
//  MessageAlignment.swift
//  FableSDKEnums
//
//  Created by Andrew Aquino on 12/24/19.
//

import UIKit

public enum Visibility: String, Codable {
  case isPrivate = "private"
  case isPublic = "public"
}

public enum ImageKey: String, Codable {
  case square
  case landscape
}

public enum MessageAlignment: String, Codable {
  case leading
  case center
  case trailing

  public var textAlignment: NSTextAlignment {
    switch self {
    case .leading: return .left
    case .center: return .center
    case .trailing: return .right
    }
  }
}
