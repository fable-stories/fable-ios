//
//  Wireable.swift
//  Fable
//
//  Created by Andrew Aquino on 11/27/19.
//

import Foundation

public protocol Wireable {
  func toWire<T: Codable>() -> T
}
