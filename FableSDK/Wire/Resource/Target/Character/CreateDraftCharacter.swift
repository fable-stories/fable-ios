//
//  CreateDraftCharacter.swift
//  Fable
//
//  Created by Andrew Aquino on 11/25/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct CreateCharacterRequestBody: Codable {
  public let storyId: Int
  public let userId: Int
  public let name: String
  public let colorHexString: String
  public let messageAlignment: String

  public init(storyId: Int, userId: Int, name: String, colorHexString: String, messageAlignment: String) {
    self.storyId = storyId
    self.userId = userId
    self.name = name
    self.colorHexString = colorHexString
    self.messageAlignment = messageAlignment
  }
}

public struct CreateCharacter: ResourceTargetProtocol {
  public typealias RequestBodyType = CreateCharacterRequestBody
  public typealias ResponseBodyType = WireCharacter

  public let method: ResourceTargetHTTPMethod = .post
  public let url: String

  public init() {
    self.url = "/character"
  }
}
