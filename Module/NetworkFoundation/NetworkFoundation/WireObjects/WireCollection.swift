//
//  WireCollection.swift
//  Fable
//
//  Created by Andrew Aquino on 8/14/19.
//

import Foundation
import AppFoundation

public struct WireCollection<T: Codable>: Codable {
  public let items: [T]
  
  public init(items: [T]) {
    self.items = items
  }
}

