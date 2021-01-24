//
//  CreateMessage.swift
//  Fable
//
//  Created by Andrew Aquino on 11/25/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct CreateMessageRequestBody: Codable {
  public let userId: Int
  public let storyId: Int
  public let chapterId: Int
  public let text: String
  public let characterId: Int?
  public let previousMessageId: Int?
  public let nextMessageId: Int?
  public let active: Bool

  public init(
    userId: Int,
    storyId: Int,
    chapterId: Int,
    text: String,
    characterId: Int?,
    previousMessageId: Int?,
    nextMessageId: Int?,
    active: Bool
  ) {
    self.userId = userId
    self.storyId = storyId
    self.chapterId = chapterId
    self.text = text
    self.characterId = characterId
    self.previousMessageId = previousMessageId
    self.nextMessageId = nextMessageId
    self.active = active
  }
}

public struct CreateMessage: ResourceTargetProtocol {
  public typealias RequestBodyType = CreateMessageRequestBody
  public typealias ResponseBodyType = WireMessage

  public let method: ResourceTargetHTTPMethod = .post
  public let url: String

  public init() {
    self.url = "/message"
  }
}
