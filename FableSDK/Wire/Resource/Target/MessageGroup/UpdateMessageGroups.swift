//
//  UpdateMessageGroups.swift
//  Fable
//
//  Created by Andrew Aquino on 11/25/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct UpdateMessageGroups: ResourceTargetProtocol {
  public typealias RequestBodyType = WireCollection<WireMessageGroup>
  public typealias ResponseBodyType = WireCollection<WireMessageGroup>

  public let method: ResourceTargetHTTPMethod = .put
  public let url: String

  public init() {
    self.url = "/creator/messageGroup"
  }
}
