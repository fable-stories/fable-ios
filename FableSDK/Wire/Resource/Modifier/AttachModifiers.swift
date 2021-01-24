//
//  AttachModifiers.swift
//  Fable
//
//  Created by Andrew Aquino on 11/25/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct AttachModifiers: ResourceTargetProtocol {
  public typealias RequestBody = WireCollection<WireModifier>
  public typealias ResponseBody = WireMessage

  public let method: ResourceTargetHTTPMethod = .put
  public let url: String

  public init(messageId: Int) {
    self.url = "/message/\(messageId)/modifier"
  }
}
