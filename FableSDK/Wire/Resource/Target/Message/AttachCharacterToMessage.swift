//
//  AttachCharacterToMessage.swift
//  FableSDKResourceTargets
//
//  Created by Andrew Aquino on 7/16/20.
//

import AppFoundation
import FableSDKWireObjects
import NetworkFoundation

public struct AttachCharacterToMessage: ResourceTargetProtocol {
  public struct RequestBody: Codable {
    public let characterId: Int?
    public init(characterId: Int?) {
      self.characterId = characterId
    }
  }
  
  public typealias RequestBodyType = RequestBody
  public typealias ResponseBodyType = WireModifier
  
  public let method: ResourceTargetHTTPMethod = .put
  public let url: String
  
  public init(messageId: Int) {
    self.url = "/message/\(messageId)/character"
  }
}
