//
//  UpdateNextMessageId.swift
//  FableSDKResourceTargets
//
//  Created by Andrew Aquino on 9/22/20.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct UpdateNextMessageId: ResourceTargetProtocol {
  public struct Request: Codable {
    public let nextMessageId: Int?

    public init(nextMessageId: Int?) {
      self.nextMessageId = nextMessageId
    }
  }

  public typealias RequestBodyType = Request
  public typealias ResponseBodyType = EmptyResponseBody
  
  public let method: ResourceTargetHTTPMethod = .put
  public let url: String
  
  public init(messageId: Int) {
    self.url = "/message/\(messageId)/next-message-id"
  }
}
public struct UpdateMessageDisplayIndex: ResourceTargetProtocol {
  public struct Request: Codable {
    public let previousMessageId: Int?
    public let nextMessageId: Int?
    
    public init(previousMessageId: Int?, nextMessageId: Int?) {
      self.previousMessageId = previousMessageId
      self.nextMessageId = nextMessageId
    }
  }
  
  public typealias RequestBodyType = Request
  public typealias ResponseBodyType = EmptyResponseBody
  
  public let method: ResourceTargetHTTPMethod = .put
  public let url: String
  
  public init(messageId: Int) {
    self.url = "/message/\(messageId)/display-index"
  }
}
