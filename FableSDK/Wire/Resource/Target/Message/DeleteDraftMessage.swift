//
//  DeleteDraftMessage.swift
//  Fable
//
//  Created by Andrew Aquino on 11/25/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct DeleteDraftMessage: ResourceTargetProtocol {
  public struct Request: Codable {
    public let previousMessageId: Int?
    public init(previousMessageId: Int?) {
      self.previousMessageId = previousMessageId
    }
  }
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = EmptyResponseBody

  public let method: ResourceTargetHTTPMethod = .delete
  public let url: String

  public init(messageId: Int) {
    self.url = "/message/\(messageId)"
  }
}
