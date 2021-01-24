//
//  WireChoiceModifier.swift
//  Fable
//
//  Created by Andrew Aquino on 11/26/19.
//

import Foundation

public struct WireChoices: Codable {
  public let choiceGroupId: Int
  public let storyId: Int?
  public let chapterId: Int?
  public let messageGroupId: Int?
  public let messageId: Int?
  public let createdAt: String?
  public let choices: [WireChoice]?

  public init(
    choiceGroupId: Int,
    storyId: Int? = nil,
    chapterId: Int? = nil,
    messageGroupId: Int? = nil,
    messageId: Int? = nil,
    createdAt: String? = nil,
    choices: [WireChoice]? = nil
  ) {
    self.choiceGroupId = choiceGroupId
    self.storyId = storyId
    self.chapterId = chapterId
    self.messageGroupId = messageGroupId
    self.messageId = messageId
    self.createdAt = createdAt
    self.choices = choices
  }
}
