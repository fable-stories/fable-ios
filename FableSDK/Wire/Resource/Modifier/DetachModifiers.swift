//
//  DetachModifier.swift
//  Fable
//
//  Created by Andrew Aquino on 11/27/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct DetachModifiers: ResourceTargetProtocol {
  public typealias RequestBody = WireCollection<Int>
  public typealias ResponseBody = WireMessage

  public let method: ResourceTargetHTTPMethod = .delete
  public let url: String

  public init(messageId: Int) {
    self.url = "/message/\(messageId)/modifier"
  }
}
