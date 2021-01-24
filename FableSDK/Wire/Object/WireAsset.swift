//
//  WireAsset.swift
//  FableSDKWireObjects
//
//  Created by MacBook Pro on 8/7/20.
//

import Foundation
import AppFoundation
import FableSDKModelObjects

public struct WireAsset: Codable {
  public let assetId: Int?
  public let objectUrl: String?
  public let tags: [String]?
}

public extension Asset {
  init?(wire: WireAsset) {
    guard
      let assetId = wire.assetId,
      let objectUrl = wire.objectUrl?.toURL()
      else { return nil }
    self.init(
      assetId: assetId,
      objectUrl: objectUrl,
      tags: wire.tags ?? []
    )
  }
  
  func toWire() -> WireAsset {
    WireAsset(
      assetId: assetId,
      objectUrl: objectUrl.absoluteString,
      tags: tags
    )
  }
}
