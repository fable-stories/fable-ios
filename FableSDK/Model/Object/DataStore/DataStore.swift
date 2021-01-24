//
//  DataStore.swift
//  FableSDKModelObjects
//
//  Created by MacBook Pro on 7/26/20.
//

import Foundation
import AppFoundation

public struct DataStore {
  public let datastoreId: Int
  public var userId: Int
  public var selectedChapterId: Int
  public var story: Story
  public var categories: [Int: Kategory]
  public var chapters: [Int: Chapter]
  public var messageGroups: [Int: MessageGroup]
  public var messages: [Int: Message]
  public var modifiers: [Int: Int]
  public var characters: [Int: Character]
  public var choices: [Int: Choice]
  public var choiceGroups: [Int: ChoiceGroup]
  public var colorHexStrings: [String]

  public init(
    datastoreId: Int = randomInt(),
    userId: Int,
    selectedChapterId: Int,
    story: Story,
    categories: [Int: Kategory]? = nil,
    chapters: [Int: Chapter]? = nil,
    messageGroups: [Int: MessageGroup]? = nil,
    messages: [Int: Message]? = nil,
    modifiers: [Int: Int]? = nil,
    characters: [Int: Character]? = nil,
    choices: [Int: Choice]? = nil,
    choiceGroups: [Int: ChoiceGroup]? = nil,
    colorHexStrings: [String]? = nil
  ) {
    self.datastoreId = datastoreId
    self.userId = userId
    self.selectedChapterId = selectedChapterId
    self.story = story
    self.categories = categories ?? [:]
    self.chapters = chapters ?? [:]
    self.messageGroups = messageGroups ?? [:]
    self.messages = messages ?? [:]
    self.modifiers = modifiers ?? [:]
    self.characters = characters ?? [:]
    self.choices = choices ?? [:]
    self.choiceGroups = choiceGroups ?? [:]
    self.colorHexStrings = colorHexStrings ?? []
  }

  public func copy(
    datastoreId: Int? = nil,
    userId: Int? = nil,
    selectedChapterId: Int? = nil,
    story: Story? = nil,
    categories: [Int: Kategory]? = nil,
    chapters: [Int: Chapter]? = nil,
    messageGroups: [Int: MessageGroup]? = nil,
    messages: [Int: Message]? = nil,
    modifiers: [Int: Int]? = nil,
    characters: [Int: Character]? = nil,
    choices: [Int: Choice]? = nil,
    choiceGroups: [Int: ChoiceGroup]? = nil,
    colorHexStrings: [String]? = nil
  ) -> DataStore {
    DataStore(
      datastoreId: datastoreId ?? self.datastoreId,
      userId: userId ?? self.userId,
      selectedChapterId: selectedChapterId ?? self.selectedChapterId,
      story: story ?? self.story,
      categories: categories ?? self.categories,
      chapters: chapters ?? self.chapters,
      messageGroups: messageGroups ?? self.messageGroups,
      messages: messages ?? self.messages,
      modifiers: modifiers ?? self.modifiers,
      characters: characters ?? self.characters,
      choices: choices ?? self.choices,
      choiceGroups: choiceGroups ?? self.choiceGroups,
      colorHexStrings: colorHexStrings ?? self.colorHexStrings
    )
  }
}

// MARK: - EquatableModel for classes, protocols, structs

// MARK: - DataStore EquatableModel

extension DataStore: Equatable {
  public static func == (lhs: DataStore, rhs: DataStore) -> Bool {
    guard lhs.datastoreId == rhs.datastoreId else { return false }
    guard lhs.userId == rhs.userId else { return false }
    guard lhs.selectedChapterId == rhs.selectedChapterId else { return false }
    guard compareOptionals(lhs: lhs.categories, rhs: rhs.categories, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.chapters, rhs: rhs.chapters, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.messageGroups, rhs: rhs.messageGroups, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.modifiers, rhs: rhs.modifiers, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.choices, rhs: rhs.choices, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.choiceGroups, rhs: rhs.choiceGroups, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.colorHexStrings, rhs: rhs.colorHexStrings, compare: ==) else { return false }
    return true
  }
}

// MARK: - HashableModel for classes, protocols, structs

// MARK: - DataStore HashableModel

extension DataStore: Hashable {
  public func hash(into hasher: inout Hasher) {
    datastoreId.hash(into: &hasher)
    userId.hash(into: &hasher)
    selectedChapterId.hash(into: &hasher)
    categories.hash(into: &hasher)
    chapters.hash(into: &hasher)
    messageGroups.hash(into: &hasher)
    modifiers.hash(into: &hasher)
    choices.hash(into: &hasher)
    choiceGroups.hash(into: &hasher)
    colorHexStrings.hash(into: &hasher)
  }
}

private func compareOptionals<T>(lhs: T?, rhs: T?, compare: (_ lhs: T, _ rhs: T) -> Bool) -> Bool {
  switch (lhs, rhs) {
  case let (lValue?, rValue?):
    return compare(lValue, rValue)
  case (nil, nil):
    return true
  default:
    return false
  }
}

private func compareArrays<T>(lhs: [T], rhs: [T], compare: (_ lhs: T, _ rhs: T) -> Bool) -> Bool {
  guard lhs.count == rhs.count else { return false }
  for (idx, lhsItem) in lhs.enumerated() {
    guard compare(lhsItem, rhs[idx]) else { return false }
  }
  return true
}
