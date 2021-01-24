//
//  BaseMessage.swift
//  FableSDKModelObjects
//
//  Created by Andrew Aquino on 1/6/20.
//

import AppFoundation
import Foundation

public protocol BaseMessage: ModelObject, WireObject {
  var messageId: Int { get }
  var userId: Int { get }
  var storyId: Int { get }
  var chapterId: Int { get }
  // sourcery: unwrap=0
  var messageGroupId: Int? { get }
  var displayIndex: Int { get }
  // sourcery: unwrap=false
  var active: Bool? { get }
  // sourcery: unwrap=""""
  var text: String? { get }
  // sourcery: unwrap=[]
  var modifierIds: Set<Int>? { get }
  var previousMessageId: Int? { get }
  var nextMessageId: Int? { get }
  // sourcery: date
  var createdAt: Date { get }
  var characterId: Int? { get }
  // sourcery: model=Character
  var character: BaseCharacter? { get }
  // sourcery: model=ChoiceGroup
  var choiceGroup: BaseChoiceGroup? { get }
}
