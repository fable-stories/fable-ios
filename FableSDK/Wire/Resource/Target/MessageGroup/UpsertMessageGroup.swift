//
//  UpsertMessageGroup.swift
//  FableSDKResourceTargets
//
//  Created by Andrew Aquino on 12/26/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct UpsertMessageGroup: ResourceTargetProtocol {
  public typealias RequestBodyType = WireCollection<WireMessageGroup>
  public typealias ResponseBodyType = WireCollection<WireMessageGroup>

  public let method: ResourceTargetHTTPMethod = .post
  public let url: String

  public init() {
    self.url = "/messageGroup"
  }
}
