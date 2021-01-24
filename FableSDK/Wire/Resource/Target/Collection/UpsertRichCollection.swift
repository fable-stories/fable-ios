//
//  UpsertRichCollection.swift
//  FableSDKResourceTargets
//
//  Created by Andrew Aquino on 12/26/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct UpsertRichCollection: ResourceTargetProtocol {
  public typealias RequestBodyType = WireRichCollection
  public typealias ResponseBodyType = WireRichCollection

  public let method: ResourceTargetHTTPMethod = .post
  public let url: String

  public init() {
    self.url = "/collection"
  }
}
