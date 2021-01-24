//
//  WireCollectionRemoveById.swift
//  FableSDKWireObjects
//
//  Created by Andrew Aquino on 1/13/20.
//

import AppFoundation
import Foundation

public struct WireCollectionRemoveById: Codable, InitializableWireObject {
  public let collection: String?
  public let modelId: Int?
}
