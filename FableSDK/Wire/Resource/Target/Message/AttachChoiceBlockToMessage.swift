//
//  AttachChoiceBlockToMessage.swift
//  Fable
//
//  Created by Andrew Aquino on 12/14/19.
//

import AppFoundation
import FableSDKWireObjects
import NetworkFoundation

public struct AttachChoiceBlockToMessage: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireRichCollection

  public let method: ResourceTargetHTTPMethod = .post
  public let url: String

  public init(messageId: Int) {
    self.url = "/creator/message/\(messageId)/choiceGroup"
  }
}
