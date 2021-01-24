//
//  DetachCharacterFromMessage.swift
//  FableSDKResourceTargets
//
//  Created by Andrew Aquino on 7/16/20.
//

import AppFoundation
import FableSDKWireObjects
import NetworkFoundation

public struct DetachCharacterFromMessage: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = EmptyResponseBody
  
  public let method: ResourceTargetHTTPMethod = .post
  public let url: String
  
  public init(messageId: Int, characterId: Int) {
    self.url = "/message/\(messageId)/modifier/\(characterId)/detach"
  }
}
