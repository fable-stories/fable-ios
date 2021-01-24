//
//  UpdateMessage.swift
//  Fable
//
//  Created by Andrew Aquino on 11/27/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct UpdateMessage: ResourceTargetProtocol {
  public struct Request: Codable {
    public let text: String?
    public let displayIndex: Int?
    public let nextMessageId: Int?
    public let active: Bool?
    
    public init(
      text: String? = nil,
      displayIndex: Int? = nil,
      nextMessageId: Int? = nil,
      active: Bool? = nil
    ) {
      self.text = text
      self.displayIndex = displayIndex
      self.nextMessageId = nextMessageId
      self.active = active
    }
  }
  public typealias RequestBodyType = Request
  public typealias ResponseBodyType = EmptyResponseBody

  public let method: ResourceTargetHTTPMethod = .put
  public let url: String

  public init(messageId: Int) {
    self.url = "/message/\(messageId)"
  }
}
