//
//  AttachChoiceModifier.swift
//  Fable
//
//  Created by Andrew Aquino on 12/12/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct AttachChoiceModifier: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = AttachChoiceModifierResponse

  public let method: ResourceTargetHTTPMethod = .put
  public let url: String

  public init(messageId: Int) {
    self.url = "/message/\(messageId)/modifier"
  }
}

public struct AttachChoiceModifierResponse: Codable {
  public let messages: [WireMessage]
  public let messageGroups: [WireMessageGroup]

  public init(messages: [WireMessage], messageGroups: [WireMessageGroup]) {
    self.messages = messages
    self.messageGroups = messageGroups
  }
}
