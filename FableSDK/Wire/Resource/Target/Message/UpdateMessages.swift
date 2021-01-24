//
//  UpsertMessages.swift
//  FableSDKResourceTargets
//
//  Created by Andrew Aquino on 12/26/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct UpsertMessages: ResourceTargetProtocol {
  public typealias RequestBodyType = WireCollection<WireMessage>
  public typealias ResponseBodyType = WireCollection<WireMessage>

  public let method: ResourceTargetHTTPMethod = .post
  public let url: String

  public init() {
    self.url = "/message"
  }
}
