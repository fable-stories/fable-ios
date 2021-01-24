//
//  WorkspaceManager+CKModel.swift
//  FableSDKViewPresenters
//
//  Created by Andrew Aquino on 12/27/19.
//

import FableSDKModelObjects
import Foundation


extension WorkspaceManager: CKModelReadOnly {
  public var story: Story {
    modelManager.story
  }

  public func fetchCategories() -> [FableSDKModelObjects.Kategory] {
    modelManager.fetchCategories()
  }

  public func fetchCategory(categoryId: Int) -> FableSDKModelObjects.Kategory? {
    modelManager.fetchCategory(categoryId: categoryId)
  }

  public func fetchChapter(chapterId: Int) -> Chapter? {
    modelManager.fetchChapter(chapterId: chapterId)
  }

  public func fetchChapters(chapterIds: [Int]) -> [Chapter] {
    modelManager.fetchChapters(chapterIds: chapterIds)
  }

  public func fetchChapters() -> [Chapter] {
    modelManager.fetchChapters()
  }

  public func fetchMessageGroups(messageGroupIds: Set<Int>) -> [MessageGroup] {
    modelManager.fetchMessageGroups(messageGroupIds: messageGroupIds)
  }

  public func fetchMessageGroup(messageGroupId: Int) -> MessageGroup? {
    modelManager.fetchMessageGroup(messageGroupId: messageGroupId)
  }

  public func fetchMessageGroups(messageGroupIds: [Int]) -> [MessageGroup] {
    modelManager.fetchMessageGroups(messageGroupIds: messageGroupIds)
  }

  public func fetchMessageGroups() -> [MessageGroup] {
    modelManager.fetchMessageGroups()
  }

  public func fetchMessage(messageId: Int) -> Message? {
    modelManager.fetchMessage(messageId: messageId)
  }

  public func fetchMessages(messageIds: Set<Int>) -> [Message] {
    modelManager.fetchMessages(messageIds: messageIds)
  }

  public func fetchMessages(messageIds: [Int]) -> [Message] {
    modelManager.fetchMessages(messageIds: messageIds)
  }

  public func fetchMessages(messageGroupId: Int) -> [Message] {
    modelManager.fetchMessages(messageGroupId: messageGroupId)
  }

  public func fetchMessages() -> [Message] {
    modelManager.fetchMessages()
  }

  public func fetchCharacterId(messageId: Int) -> Int? {
    let message = fetchMessage(messageId: messageId)
    return message?.characterId
  }

  public func fetchCharacter(modifierId: Int) -> Character? {
    modelManager.fetchCharacter(modifierId: modifierId)
  }

  public func fetchCharacter(characterId: Int) -> Character? {
    modelManager.fetchCharacter(characterId: characterId)
  }

  public func fetchCharacter(messageId: Int) -> Character? {
    modelManager.fetchCharacter(messageId: messageId)
  }

  public func fetchCharacters() -> [Character] {
    modelManager.fetchCharacters()
  }

  public func fetchCharacters(characterIds: Set<Int>) -> [Character] {
    modelManager.fetchCharacters(characterIds: characterIds)
  }

  public func fetchChoice(choiceId: Int) -> Choice? {
    modelManager.fetchChoice(choiceId: choiceId)
  }

  public func fetchChoiceGroup(modifierId: Int) -> ChoiceGroup? {
    modelManager.fetchChoiceGroup(modifierId: modifierId)
  }

  public func fetchChoiceGroup(choiceGroupId: Int) -> ChoiceGroup? {
    modelManager.fetchChoiceGroup(choiceGroupId: choiceGroupId)
  }

  public func fetchChoiceGroups() -> [ChoiceGroup] {
    modelManager.fetchChoiceGroups()
  }

  public func fetchColorHexStrings() -> [String] {
    modelManager.fetchColorHexStrings()
  }
}
