//
//  Protocol.swift
//  FableSDKModelObjects
//
//  Created by Andrew Aquino on 1/15/20.
//

import Foundation

public protocol CKModelWriteOnly {
  mutating func insert(categories: [Kategory])
  mutating func insert(chapter: Chapter)
  mutating func insert(chapters: [Chapter])
  mutating func insert(messageGroup: MessageGroup)
  mutating func insert(messageGroups: [MessageGroup])
  mutating func insert(message: Message)
  mutating func insert(messages: [Message])
  mutating func insert(character: Character)
  mutating func insert(characters: [Character])
  mutating func insert(choice: Choice)
  mutating func insert(choiceGroup: ChoiceGroup)
  mutating func insert(colorHexStrings: [String])

  mutating func remove(categoryIds: Set<Int>)
  mutating func remove(chapterIds: Set<Int>)
  mutating func remove(messageGroupIds: Set<Int>)
  mutating func remove(messageIds: Set<Int>)
  mutating func remove(characterIds: Set<Int>)
  mutating func remove(modifierId: Int)

  mutating func clear()
}

public protocol CKModelReadOnly {
  var story: Story { get }

  func fetchCategory(categoryId: Int) -> Kategory?
  func fetchCategories() -> [Kategory]

  func fetchChapter(chapterId: Int) -> Chapter?
  func fetchChapters(chapterIds: [Int]) -> [Chapter]
  func fetchChapters() -> [Chapter]

  func fetchMessageGroup(messageGroupId: Int) -> MessageGroup?
  func fetchMessageGroups(messageGroupIds: [Int]) -> [MessageGroup]
  func fetchMessageGroups(messageGroupIds: Set<Int>) -> [MessageGroup]
  func fetchMessageGroups() -> [MessageGroup]

  func fetchMessage(messageId: Int) -> Message?
  func fetchMessages(messageIds: [Int]) -> [Message]
  func fetchMessages(messageIds: Set<Int>) -> [Message]
  func fetchMessages(messageGroupId: Int) -> [Message]
  func fetchMessages() -> [Message]

  func fetchCharacter(messageId: Int) -> Character?
  func fetchCharacter(characterId: Int) -> Character?
  func fetchCharacter(modifierId: Int) -> Character?
  func fetchCharacterId(messageId: Int) -> Int?
  func fetchCharacters(characterIds: Set<Int>) -> [Character]
  func fetchCharacters() -> [Character]

  func fetchChoice(choiceId: Int) -> Choice?
  func fetchChoiceGroup(modifierId: Int) -> ChoiceGroup?
  func fetchChoiceGroup(choiceGroupId: Int) -> ChoiceGroup?
  func fetchChoiceGroups() -> [ChoiceGroup]

  func fetchColorHexStrings() -> [String]
}
