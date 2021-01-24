//
//  DataStore+Extension.swift
//  FableSDKModelObjects
//
//  Created by Andrew Aquino on 1/11/20.
//

import Foundation

extension DataStore: CKModelWriteOnly, CKModelReadOnly {
  // MARK: - Write

  public mutating func insert(categories: [Kategory]) {
    self.categories = categories.indexed(by: { $0.categoryId })
  }

  public mutating func insert(chapter: Chapter) {
    chapters[chapter.chapterId] = chapter
  }

  public mutating func insert(chapters: [Chapter]) {
    self.chapters.merge(
      chapters.indexed(by: { $0.chapterId }),
      uniquingKeysWith: { _, new in new }
    )
  }

  public mutating func insert(messageGroup: MessageGroup) {
    messageGroups[messageGroup.messageGroupId] = messageGroup
  }

  public mutating func insert(messageGroups: [MessageGroup]) {
    self.messageGroups.merge(
      messageGroups.indexed(by: { $0.messageGroupId }),
      uniquingKeysWith: { _, new in new }
    )
  }

  public mutating func insert(message: Message) {
//    messages[message.messageId] = message
  }

  public mutating func insert(messages: [Message]) {
//    self.messages.merge(
//      messages.indexed(by: { $0.messageId }),
//      uniquingKeysWith: { _, new in new }
//    )
  }

  public mutating func insert(character: Character) {
  }

  public mutating func insert(characters: [Character]) {
  }

  public mutating func insert(choice: Choice) {
    choices[choice.choiceId] = choice
  }

  public mutating func insert(choiceGroup: ChoiceGroup) {
    choiceGroups[choiceGroup.choiceGroupId] = choiceGroup
    modifiers[choiceGroup.modifierId] = choiceGroup.choiceGroupId
  }

  public mutating func insert(colorHexStrings: [String]) {
    self.colorHexStrings = colorHexStrings
  }

  public mutating func remove(categoryIds: Set<Int>) {
    categoryIds.forEach { self.categories[$0] = nil }
  }

  public mutating func remove(chapterIds: Set<Int>) {
    chapterIds.forEach { self.chapters[$0] = nil }
  }

  public mutating func remove(messageGroupIds: Set<Int>) {
    messageGroupIds.forEach { self.messageGroups[$0] = nil }
  }

  public mutating func remove(messageIds: Set<Int>) {
    messageIds.forEach { self.messages[$0] = nil }
  }

  public mutating func remove(characterIds: Set<Int>) {
    characterIds.forEach { characters[$0] = nil }
  }

  public mutating func remove(modifierId: Int) {
    modifiers[modifierId] = nil
  }

  public mutating func clear() {
    chapters.removeAll()
    modifiers.removeAll()
    messages.removeAll()
    messageGroups.removeAll()
  }

  // MARK: - Read

  public func fetchCategories() -> [Kategory] {
    Array(categories.values)
  }

  public func fetchCategory(categoryId: Int) -> Kategory? {
    categories[categoryId]
  }

  public func fetchChapter(chapterId: Int) -> Chapter? {
    chapters[chapterId]
  }

  public func fetchChapters(chapterIds: [Int]) -> [Chapter] {
    chapterIds.compactMap { chapters[$0] }
  }

  public func fetchChapters() -> [Chapter] {
    Array(chapters.values)
  }

  public func fetchMessageGroup(messageGroupId: Int) -> MessageGroup? {
    messageGroups[messageGroupId]
  }

  public func fetchMessageGroups(messageGroupIds: [Int]) -> [MessageGroup] {
    messageGroupIds.compactMap { messageGroups[$0] }
  }

  public func fetchMessageGroups(messageGroupIds: Set<Int>) -> [MessageGroup] {
    messageGroupIds.compactMap { messageGroups[$0] }
  }

  public func fetchMessageGroups() -> [MessageGroup] {
    Array(messageGroups.values)
  }
  
  public func fetchNewMessage() -> Message? {
//    fetchMessages().first(where: \.active)
    return nil
  }

  public func fetchMessage(messageId: Int) -> Message? {
    messages[messageId]
  }

  public func fetchMessages(messageIds: [Int]) -> [Message] {
    messageIds.compactMap { messages[$0] }
  }

  public func fetchMessages(messageIds: Set<Int>) -> [Message] {
    messageIds.compactMap { messages[$0] }
  }

  public func fetchMessages(messageGroupId: Int) -> [Message] {
    messages.values.filter { $0.messageGroupId == messageGroupId }
  }

  public func fetchMessages() -> [Message] {
    Array(messages.values)
  }

  public func fetchCharacter(characterId: Int) -> Character? {
    characters[characterId]
  }
  
  public func fetchCharacter(messageId: Int) -> Character? {
    guard let characterId = messages.values.filter({ $0.messageId == messageId }).first?.characterId else { return nil }
    return fetchCharacter(characterId: characterId)
  }
  
  public func fetchCharacterId(messageId: Int) -> Int? {
    messages.values.filter { $0.messageId == messageId }.first?.characterId
  }

  public func fetchCharacter(modifierId: Int) -> Character? {
    guard let characterId = modifiers[modifierId] else { return nil }
    return fetchCharacter(characterId: characterId)
  }

  public func fetchCharacters(characterIds: Set<Int>) -> [Character] {
    characterIds.compactMap { characters[$0] }
  }

  public func fetchCharacters() -> [Character] {
    Array(characters.values)
  }

  public func fetchChoice(choiceId: Int) -> Choice? {
    choices[choiceId]
  }

  public func fetchChoiceGroup(modifierId: Int) -> ChoiceGroup? {
    guard let choiceGroupId = modifiers[modifierId] else { return nil }
    return fetchChoiceGroup(choiceGroupId: choiceGroupId)
  }

  public func fetchChoiceGroup(choiceGroupId: Int) -> ChoiceGroup? {
    choiceGroups[choiceGroupId]
  }

  public func fetchChoiceGroups() -> [ChoiceGroup] {
    Array(choiceGroups.values)
  }

  public func fetchColorHexStrings() -> [String] {
    colorHexStrings
  }
}
