// Generated using Sourcery 0.18.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

// swiftlint:disable file_length
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

import AppFoundation
import FableSDKEnums
import Foundation

// MARK: - Asset

public struct Asset: Codable {
  public let assetId: Int
  public let objectUrl: URL
  public let tags: [String]

  public init(
    assetId: Int,
    objectUrl: URL,
    tags: [String]
  ) {
    self.assetId = assetId
    self.objectUrl = objectUrl
    self.tags = tags
  }

  public func copy(
    assetId: Int? = nil,
    objectUrl: URL? = nil,
    tags: [String]? = nil
  ) -> Asset {
    Asset(
      assetId: assetId ?? self.assetId,
      objectUrl: objectUrl ?? self.objectUrl,
      tags: tags ?? self.tags
    )
  }
}

extension Asset: Equatable {
  public static func == (lhs: Asset, rhs: Asset) -> Bool {
    guard lhs.assetId == rhs.assetId else { return false }
    guard lhs.objectUrl == rhs.objectUrl else { return false }
    guard lhs.tags == rhs.tags else { return false }
    return true
  }
}

extension Asset: Hashable {
  public func hash(into hasher: inout Hasher) {
    assetId.hash(into: &hasher)
    objectUrl.hash(into: &hasher)
    tags.hash(into: &hasher)
  }
}

// MARK: - Chapter

public struct Chapter: Codable {
  public let chapterId: Int
  public let storyId: Int
  public let title: String
  public let index: Int?
  public let messageGroupIds: Set<Int>
  public let selectedMessageGroupIds: Set<Int>
  public let previousChapterId: Int?
  public let nextChapterId: Int?
  public let createdAt: Date

  public init(
    chapterId: Int,
    storyId: Int,
    title: String? = nil,
    index: Int? = nil,
    messageGroupIds: Set<Int>? = nil,
    selectedMessageGroupIds: Set<Int>? = nil,
    previousChapterId: Int? = nil,
    nextChapterId: Int? = nil,
    createdAt: Date
  ) {
    self.chapterId = chapterId
    self.storyId = storyId
    self.title = title ?? ""
    self.index = index
    self.messageGroupIds = messageGroupIds ?? []
    self.selectedMessageGroupIds = selectedMessageGroupIds ?? []
    self.previousChapterId = previousChapterId
    self.nextChapterId = nextChapterId
    self.createdAt = createdAt
  }

  public func copy(
    chapterId: Int? = nil,
    storyId: Int? = nil,
    title: String? = nil,
    index: Int? = nil,
    messageGroupIds: Set<Int>? = nil,
    selectedMessageGroupIds: Set<Int>? = nil,
    previousChapterId: Int? = nil,
    nextChapterId: Int? = nil,
    createdAt: Date? = nil
  ) -> Chapter {
    Chapter(
      chapterId: chapterId ?? self.chapterId,
      storyId: storyId ?? self.storyId,
      title: title ?? self.title,
      index: index ?? self.index,
      messageGroupIds: messageGroupIds ?? self.messageGroupIds,
      selectedMessageGroupIds: selectedMessageGroupIds ?? self.selectedMessageGroupIds,
      previousChapterId: previousChapterId ?? self.previousChapterId,
      nextChapterId: nextChapterId ?? self.nextChapterId,
      createdAt: createdAt ?? self.createdAt
    )
  }
}

extension Chapter: Equatable {
  public static func == (lhs: Chapter, rhs: Chapter) -> Bool {
    guard lhs.chapterId == rhs.chapterId else { return false }
    guard lhs.storyId == rhs.storyId else { return false }
    guard compareOptionals(lhs: lhs.title, rhs: rhs.title, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.index, rhs: rhs.index, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.messageGroupIds, rhs: rhs.messageGroupIds, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.selectedMessageGroupIds, rhs: rhs.selectedMessageGroupIds, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.previousChapterId, rhs: rhs.previousChapterId, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.nextChapterId, rhs: rhs.nextChapterId, compare: ==) else { return false }
    guard lhs.createdAt == rhs.createdAt else { return false }
    return true
  }
}

extension Chapter: Hashable {
  public func hash(into hasher: inout Hasher) {
    chapterId.hash(into: &hasher)
    storyId.hash(into: &hasher)
    title.hash(into: &hasher)
    index.hash(into: &hasher)
    messageGroupIds.hash(into: &hasher)
    selectedMessageGroupIds.hash(into: &hasher)
    previousChapterId.hash(into: &hasher)
    nextChapterId.hash(into: &hasher)
    createdAt.hash(into: &hasher)
  }
}

// MARK: - Character

public protocol Character: Codable {
  var characterId: Int { get }
  var userId: Int { get }
  var storyId: Int { get }
  var name: String { get }
  var colorHexString: String? { get }
  var messageAlignment: MessageAlignment { get }
  var createdAt: Date { get }

  init(
    characterId: Int,
    userId: Int,
    storyId: Int,
    name: String?,
    colorHexString: String?,
    messageAlignment: MessageAlignment?,
    createdAt: Date
  )
}

extension Character {
  public func copy(
    characterId: Int? = nil,
    userId: Int? = nil,
    storyId: Int? = nil,
    name: String? = nil,
    colorHexString: String? = nil,
    messageAlignment: MessageAlignment? = nil,
    createdAt: Date? = nil
  ) -> Character {
    MutableCharacter(
      characterId: characterId ?? self.characterId,
      userId: userId ?? self.userId,
      storyId: storyId ?? self.storyId,
      name: name ?? self.name,
      colorHexString: colorHexString ?? self.colorHexString,
      messageAlignment: messageAlignment ?? self.messageAlignment,
      createdAt: createdAt ?? self.createdAt
    )
  }
}

public class MutableCharacter: Character {
  public let characterId: Int
  public var userId: Int
  public var storyId: Int
  public var name: String
  public var colorHexString: String?
  public var messageAlignment: MessageAlignment
  public var createdAt: Date
  
  public required init(
    characterId: Int,
    userId: Int,
    storyId: Int,
    name: String?,
    colorHexString: String?,
    messageAlignment: MessageAlignment?,
    createdAt: Date
  ) {
    self.characterId = characterId
    self.userId = userId
    self.storyId = storyId
    self.name = name ?? ""
    self.colorHexString = colorHexString
    self.messageAlignment = messageAlignment ?? .center
    self.createdAt = createdAt
  }
  
  public convenience init(character: Character) {
    self.init(
      characterId: character.characterId,
      userId: character.userId,
      storyId: character.storyId,
      name: character.name,
      colorHexString: character.colorHexString,
      messageAlignment: character.messageAlignment,
      createdAt: character.createdAt
    )
  }
}

// MARK: - Choice

public struct Choice: Codable {
  public let choiceId: Int
  public let choiceGroupId: Int
  public let choiceText: String
  public let createdAt: Date
  public let targetMessageGroupId: Int?

  public init(
    choiceId: Int,
    choiceGroupId: Int,
    choiceText: String? = nil,
    createdAt: Date,
    targetMessageGroupId: Int? = nil
  ) {
    self.choiceId = choiceId
    self.choiceGroupId = choiceGroupId
    self.choiceText = choiceText ?? ""
    self.createdAt = createdAt
    self.targetMessageGroupId = targetMessageGroupId
  }

  public func copy(
    choiceId: Int? = nil,
    choiceGroupId: Int? = nil,
    choiceText: String? = nil,
    createdAt: Date? = nil,
    targetMessageGroupId: Int? = nil
  ) -> Choice {
    Choice(
      choiceId: choiceId ?? self.choiceId,
      choiceGroupId: choiceGroupId ?? self.choiceGroupId,
      choiceText: choiceText ?? self.choiceText,
      createdAt: createdAt ?? self.createdAt,
      targetMessageGroupId: targetMessageGroupId ?? self.targetMessageGroupId
    )
  }
}

extension Choice: Equatable {
  public static func == (lhs: Choice, rhs: Choice) -> Bool {
    guard lhs.choiceId == rhs.choiceId else { return false }
    guard lhs.choiceGroupId == rhs.choiceGroupId else { return false }
    guard compareOptionals(lhs: lhs.choiceText, rhs: rhs.choiceText, compare: ==) else { return false }
    guard lhs.createdAt == rhs.createdAt else { return false }
    guard compareOptionals(lhs: lhs.targetMessageGroupId, rhs: rhs.targetMessageGroupId, compare: ==) else { return false }
    return true
  }
}

extension Choice: Hashable {
  public func hash(into hasher: inout Hasher) {
    choiceId.hash(into: &hasher)
    choiceGroupId.hash(into: &hasher)
    choiceText.hash(into: &hasher)
    createdAt.hash(into: &hasher)
    targetMessageGroupId.hash(into: &hasher)
  }
}

// MARK: - ChoiceGroup

public struct ChoiceGroup: Codable {
  public let choiceGroupId: Int
  public let modifierId: Int
  public let modifierKind: ModifierKind
  public let userId: Int
  public let storyId: Int
  public let messageId: Int
  public let messageGroupId: Int
  public let choices: [Choice]
  public let createdAt: Date

  public init(
    choiceGroupId: Int,
    modifierId: Int,
    modifierKind: ModifierKind,
    userId: Int,
    storyId: Int,
    messageId: Int,
    messageGroupId: Int,
    choices: [Choice]? = nil,
    createdAt: Date
  ) {
    self.choiceGroupId = choiceGroupId
    self.modifierId = modifierId
    self.modifierKind = modifierKind
    self.userId = userId
    self.storyId = storyId
    self.messageId = messageId
    self.messageGroupId = messageGroupId
    self.choices = choices ?? []
    self.createdAt = createdAt
  }

  public func copy(
    choiceGroupId: Int? = nil,
    modifierId: Int? = nil,
    modifierKind: ModifierKind? = nil,
    userId: Int? = nil,
    storyId: Int? = nil,
    messageId: Int? = nil,
    messageGroupId: Int? = nil,
    choices: [Choice]? = nil,
    createdAt: Date? = nil
  ) -> ChoiceGroup {
    ChoiceGroup(
      choiceGroupId: choiceGroupId ?? self.choiceGroupId,
      modifierId: modifierId ?? self.modifierId,
      modifierKind: modifierKind ?? self.modifierKind,
      userId: userId ?? self.userId,
      storyId: storyId ?? self.storyId,
      messageId: messageId ?? self.messageId,
      messageGroupId: messageGroupId ?? self.messageGroupId,
      choices: choices ?? self.choices,
      createdAt: createdAt ?? self.createdAt
    )
  }
}

extension ChoiceGroup: Equatable {
  public static func == (lhs: ChoiceGroup, rhs: ChoiceGroup) -> Bool {
    guard lhs.choiceGroupId == rhs.choiceGroupId else { return false }
    guard lhs.modifierId == rhs.modifierId else { return false }
    guard lhs.modifierKind == rhs.modifierKind else { return false }
    guard lhs.userId == rhs.userId else { return false }
    guard lhs.storyId == rhs.storyId else { return false }
    guard lhs.messageId == rhs.messageId else { return false }
    guard lhs.messageGroupId == rhs.messageGroupId else { return false }
    guard compareOptionals(lhs: lhs.choices, rhs: rhs.choices, compare: ==) else { return false }
    guard lhs.createdAt == rhs.createdAt else { return false }
    return true
  }
}

extension ChoiceGroup: Hashable {
  public func hash(into hasher: inout Hasher) {
    choiceGroupId.hash(into: &hasher)
    modifierId.hash(into: &hasher)
    modifierKind.hash(into: &hasher)
    userId.hash(into: &hasher)
    storyId.hash(into: &hasher)
    messageId.hash(into: &hasher)
    messageGroupId.hash(into: &hasher)
    choices.hash(into: &hasher)
    createdAt.hash(into: &hasher)
  }
}

// MARK: - Config

public struct Config: Codable {
  public let configId: Int
  public let colorHexStrings: [String]
  public let enableInteractiveStories: Bool
  public let admins: [String]
  public let resourceConfig: ResourceConfig?

  public init(
    configId: Int,
    colorHexStrings: [String]? = nil,
    enableInteractiveStories: Bool? = nil,
    admins: [String]? = nil,
    resourceConfig: ResourceConfig? = nil
  ) {
    self.configId = configId
    self.colorHexStrings = colorHexStrings ?? []
    self.enableInteractiveStories = enableInteractiveStories ?? false
    self.admins = admins ?? []
    self.resourceConfig = resourceConfig
  }

  public func copy(
    configId: Int? = nil,
    colorHexStrings: [String]? = nil,
    enableInteractiveStories: Bool? = nil,
    admins: [String]? = nil,
    resourceConfig: ResourceConfig? = nil
  ) -> Config {
    Config(
      configId: configId ?? self.configId,
      colorHexStrings: colorHexStrings ?? self.colorHexStrings,
      enableInteractiveStories: enableInteractiveStories ?? self.enableInteractiveStories,
      admins: admins ?? self.admins,
      resourceConfig: resourceConfig ?? self.resourceConfig
    )
  }
}

extension Config: Equatable {
  public static func == (lhs: Config, rhs: Config) -> Bool {
    guard lhs.configId == rhs.configId else { return false }
    guard compareOptionals(lhs: lhs.colorHexStrings, rhs: rhs.colorHexStrings, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.enableInteractiveStories, rhs: rhs.enableInteractiveStories, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.admins, rhs: rhs.admins, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.resourceConfig, rhs: rhs.resourceConfig, compare: ==) else { return false }
    return true
  }
}

extension Config: Hashable {
  public func hash(into hasher: inout Hasher) {
    configId.hash(into: &hasher)
    colorHexStrings.hash(into: &hasher)
    enableInteractiveStories.hash(into: &hasher)
    admins.hash(into: &hasher)
    resourceConfig.hash(into: &hasher)
  }
}

// MARK: - Feed

public struct Feed {
  public let categories: [Kategory]
  public let stories: [Int: Story]

  public init(
    categories: [Kategory]? = nil,
    stories: [Int: Story]? = nil
  ) {
    self.categories = categories ?? []
    self.stories = stories ?? [:]
  }

  public func copy(
    categories: [Kategory]? = nil,
    stories: [Int: Story]? = nil
  ) -> Feed {
    Feed(
      categories: categories ?? self.categories,
      stories: stories ?? self.stories
    )
  }
}

extension Feed: Equatable {
  public static func == (lhs: Feed, rhs: Feed) -> Bool {
    guard compareOptionals(lhs: lhs.categories, rhs: rhs.categories, compare: ==) else { return false }
    return true
  }
}

extension Feed: Hashable {
  public func hash(into hasher: inout Hasher) {
    categories.hash(into: &hasher)
  }
}

// MARK: - Kategory

public struct Kategory {
  public let categoryId: Int
  public let title: String
  public let subtitle: String
  public let stories: [Story]

  public init(
    categoryId: Int,
    title: String? = nil,
    subtitle: String? = nil,
    stories: [Story]? = nil
  ) {
    self.categoryId = categoryId
    self.title = title ?? ""
    self.subtitle = subtitle ?? ""
    self.stories = stories ?? []
  }

  public func copy(
    categoryId: Int? = nil,
    title: String? = nil,
    subtitle: String? = nil,
    stories: [Story]? = nil
  ) -> Kategory {
    Kategory(
      categoryId: categoryId ?? self.categoryId,
      title: title ?? self.title,
      subtitle: subtitle ?? self.subtitle,
      stories: stories ?? self.stories
    )
  }
}

extension Kategory: Equatable {
  public static func == (lhs: Kategory, rhs: Kategory) -> Bool {
    guard lhs.categoryId == rhs.categoryId else { return false }
    guard compareOptionals(lhs: lhs.title, rhs: rhs.title, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.subtitle, rhs: rhs.subtitle, compare: ==) else { return false }
    return true
  }
}

extension Kategory: Hashable {
  public func hash(into hasher: inout Hasher) {
    categoryId.hash(into: &hasher)
    title.hash(into: &hasher)
    subtitle.hash(into: &hasher)
  }
}

// MARK: - Message

public protocol Message {
  var messageId: Int { get }
  var userId: Int { get }
  var storyId: Int { get }
  var chapterId: Int { get }
  var messageGroupId: Int { get }
  var displayIndex: Int { get }
  var active: Bool { get }
  var text: String { get }
  var modifierIds: Set<Int> { get }
  var previousMessageId: Int? { get }
  var nextMessageId: Int? { get }
  var createdAt: Date { get }
  var characterId: Int? { get }
  var character: Character? { get }
  var choiceGroup: ChoiceGroup? { get }
  
  init(
    messageId: Int,
    userId: Int,
    storyId: Int,
    chapterId: Int,
    messageGroupId: Int?,
    displayIndex: Int,
    active: Bool?,
    text: String?,
    modifierIds: Set<Int>?,
    previousMessageId: Int?,
    nextMessageId: Int?,
    createdAt: Date,
    characterId: Int?,
    character: Character?,
    choiceGroup: ChoiceGroup?
  )
}

public extension Message {
  func copy(
    messageId: Int? = nil,
    userId: Int? = nil,
    storyId: Int? = nil,
    chapterId: Int? = nil,
    messageGroupId: Int? = nil,
    displayIndex: Int? = nil,
    active: Bool? = nil,
    text: String? = nil,
    modifierIds: Set<Int>? = nil,
    previousMessageId: Int? = nil,
    nextMessageId: Int? = nil,
    createdAt: Date? = nil,
    characterId: Int? = nil,
    character: Character? = nil,
    choiceGroup: ChoiceGroup? = nil
  ) -> Message {
    MutableMessage(message: self)
  }
}

public class MutableMessage: Message {
  public var messageId: Int
  public var userId: Int
  public var storyId: Int
  public var chapterId: Int
  public var messageGroupId: Int
  public var displayIndex: Int
  public var active: Bool
  public var text: String
  public var modifierIds: Set<Int>
  public var previousMessageId: Int?
  public var nextMessageId: Int?
  public var createdAt: Date
  public var characterId: Int?
  public var character: Character?
  public var choiceGroup: ChoiceGroup?
  
  public required init(
    messageId: Int,
    userId: Int,
    storyId: Int,
    chapterId: Int,
    messageGroupId: Int?,
    displayIndex: Int,
    active: Bool?,
    text: String?,
    modifierIds: Set<Int>?,
    previousMessageId: Int?,
    nextMessageId: Int?, createdAt: Date,
    characterId: Int?,
    character: Character?,
    choiceGroup: ChoiceGroup?
  ) {
    self.messageId = messageId
    self.userId = userId
    self.storyId = storyId
    self.chapterId = chapterId
    self.messageGroupId = messageGroupId ?? 0
    self.displayIndex = displayIndex
    self.active = active ?? false
    self.text = text ?? ""
    self.modifierIds = modifierIds ?? []
    self.previousMessageId = previousMessageId
    self.nextMessageId = nextMessageId
    self.createdAt = createdAt
    self.characterId = characterId
    self.character = character
    self.choiceGroup = choiceGroup
  }

  public init(message: Message) {
    self.messageId = message.messageId
    self.userId = message.userId
    self.storyId = message.storyId
    self.chapterId = message.chapterId
    self.messageGroupId = message.messageGroupId
    self.displayIndex = message.displayIndex
    self.active = message.active
    self.text = message.text
    self.modifierIds = message.modifierIds
    self.previousMessageId = message.previousMessageId
    self.nextMessageId = message.nextMessageId
    self.createdAt = message.createdAt
    self.characterId = message.characterId
    self.character = message.character
    self.choiceGroup = message.choiceGroup
  }
}

// MARK: - MessageGroup

public struct MessageGroup: Codable {
  public let messageGroupId: Int
  public let storyId: Int
  public let chapterId: Int
  public let userId: Int
  public let messageGroupTitle: String
  public let index: Int?
  public let previousMessageGroupId: Int?
  public let nextMessageGroupId: Int?
  public let sourceMessageId: Int?
  public let createdAt: Date

  public init(
    messageGroupId: Int,
    storyId: Int,
    chapterId: Int,
    userId: Int,
    messageGroupTitle: String? = nil,
    index: Int? = nil,
    previousMessageGroupId: Int? = nil,
    nextMessageGroupId: Int? = nil,
    sourceMessageId: Int? = nil,
    createdAt: Date
  ) {
    self.messageGroupId = messageGroupId
    self.storyId = storyId
    self.chapterId = chapterId
    self.userId = userId
    self.messageGroupTitle = messageGroupTitle ?? ""
    self.index = index
    self.previousMessageGroupId = previousMessageGroupId
    self.nextMessageGroupId = nextMessageGroupId
    self.sourceMessageId = sourceMessageId
    self.createdAt = createdAt
  }

  public func copy(
    messageGroupId: Int? = nil,
    storyId: Int? = nil,
    chapterId: Int? = nil,
    userId: Int? = nil,
    messageGroupTitle: String? = nil,
    index: Int? = nil,
    previousMessageGroupId: Int? = nil,
    nextMessageGroupId: Int? = nil,
    sourceMessageId: Int? = nil,
    createdAt: Date? = nil
  ) -> MessageGroup {
    MessageGroup(
      messageGroupId: messageGroupId ?? self.messageGroupId,
      storyId: storyId ?? self.storyId,
      chapterId: chapterId ?? self.chapterId,
      userId: userId ?? self.userId,
      messageGroupTitle: messageGroupTitle ?? self.messageGroupTitle,
      index: index ?? self.index,
      previousMessageGroupId: previousMessageGroupId ?? self.previousMessageGroupId,
      nextMessageGroupId: nextMessageGroupId ?? self.nextMessageGroupId,
      sourceMessageId: sourceMessageId ?? self.sourceMessageId,
      createdAt: createdAt ?? self.createdAt
    )
  }
}

extension MessageGroup: Equatable {
  public static func == (lhs: MessageGroup, rhs: MessageGroup) -> Bool {
    guard lhs.messageGroupId == rhs.messageGroupId else { return false }
    guard lhs.storyId == rhs.storyId else { return false }
    guard lhs.chapterId == rhs.chapterId else { return false }
    guard lhs.userId == rhs.userId else { return false }
    guard compareOptionals(lhs: lhs.messageGroupTitle, rhs: rhs.messageGroupTitle, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.index, rhs: rhs.index, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.previousMessageGroupId, rhs: rhs.previousMessageGroupId, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.nextMessageGroupId, rhs: rhs.nextMessageGroupId, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.sourceMessageId, rhs: rhs.sourceMessageId, compare: ==) else { return false }
    guard lhs.createdAt == rhs.createdAt else { return false }
    return true
  }
}

extension MessageGroup: Hashable {
  public func hash(into hasher: inout Hasher) {
    messageGroupId.hash(into: &hasher)
    storyId.hash(into: &hasher)
    chapterId.hash(into: &hasher)
    userId.hash(into: &hasher)
    messageGroupTitle.hash(into: &hasher)
    index.hash(into: &hasher)
    previousMessageGroupId.hash(into: &hasher)
    nextMessageGroupId.hash(into: &hasher)
    sourceMessageId.hash(into: &hasher)
    createdAt.hash(into: &hasher)
  }
}

// MARK: - ResourceConfig

public struct ResourceConfig: Codable {
  public init(
  ) {}

  public func copy(
  ) -> ResourceConfig {
    ResourceConfig(
    )
  }
}

extension ResourceConfig: Equatable {
  public static func == (lhs: ResourceConfig, rhs: ResourceConfig) -> Bool {
    true
  }
}

extension ResourceConfig: Hashable {
  public func hash(into hasher: inout Hasher) {}
}

// MARK: - State

public struct State: Codable {
  public let appSessionId: String
  public var currentUser: User?
  public var config: Config?

  public init(
    appSessionId: String,
    currentUser: User? = nil,
    config: Config? = nil
  ) {
    self.appSessionId = appSessionId
    self.currentUser = currentUser
    self.config = config
  }

  public func copy(
    appSessionId: String? = nil,
    currentUser: User? = nil,
    config: Config? = nil
  ) -> State {
    State(
      appSessionId: appSessionId ?? self.appSessionId,
      currentUser: currentUser ?? self.currentUser,
      config: config ?? self.config
    )
  }
}

extension State: Equatable {
  public static func == (lhs: State, rhs: State) -> Bool {
    guard lhs.appSessionId == rhs.appSessionId else { return false }
    guard compareOptionals(lhs: lhs.currentUser, rhs: rhs.currentUser, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.config, rhs: rhs.config, compare: ==) else { return false }
    return true
  }
}

extension State: Hashable {
  public func hash(into hasher: inout Hasher) {
    appSessionId.hash(into: &hasher)
    currentUser.hash(into: &hasher)
    config.hash(into: &hasher)
  }
}

// MARK: - Story

public protocol Story: Codable {
  var storyId: Int { get }
  var userId: Int { get }
  var categoryId: Int? { get }
  var title: String { get }
  var synopsis: String { get }
  var chapterIds: Set<Int> { get }
  var isPublished: Bool { get }
  var landscapeImageAssetId: Int? { get }
  var portraitImageAssetId: Int? { get }
  var squareImageAssetId: Int? { get}
  
  /// Transients
  var landscapeImageAsset: Asset? { get }
  var squareImageAsset: Asset? { get }
  var portraitImageAsset: Asset? { get }

  init(
    storyId: Int,
    userId: Int,
    categoryId: Int?,
    title: String?,
    synopsis: String?,
    chapterIds: Set<Int>?,
    isPublished: Bool,
    portraitImageAssetId: Int?,
    portraitImageAsset: Asset?,
    landscapeImageAssetId: Int?,
    landscapeImageAsset: Asset?,
    squareImageAssetId: Int?,
    squareImageAsset: Asset?
  )
}

public extension Story {
  func copy(
    storyId: Int? = nil,
    userId: Int? = nil,
    categoryId: Int? = nil,
    title: String? = nil,
    synopsis: String? = nil,
    chapterIds: Set<Int>? = nil,
    isPublished: Bool? = nil,
    portraitImageAssetId: Int? = nil,
    portraitImageAsset: Asset? = nil,
    landscapeImageAssetId: Int? = nil,
    landscapeImageAsset: Asset? = nil,
    squareImageAssetId: Int? = nil,
    squareImageAsset: Asset? = nil
  ) -> Story {
    MutableStory(
      storyId: storyId ?? self.storyId,
      userId: userId ?? self.userId,
      categoryId: categoryId ?? self.categoryId,
      title: title ?? self.title,
      synopsis: synopsis ?? self.synopsis,
      chapterIds: chapterIds ?? self.chapterIds,
      isPublished: isPublished ?? self.isPublished,
      portraitImageAssetId: portraitImageAssetId ?? self.portraitImageAssetId,
      portraitImageAsset: portraitImageAsset ?? self.portraitImageAsset,
      landscapeImageAssetId: landscapeImageAssetId ?? self.portraitImageAssetId,
      landscapeImageAsset: landscapeImageAsset ?? self.portraitImageAsset,
      squareImageAssetId: squareImageAssetId ?? self.squareImageAssetId,
      squareImageAsset: squareImageAsset ?? self.squareImageAsset
    )
  }
}

public class MutableStory: Story {
  public let storyId: Int
  public let userId: Int
  public var categoryId: Int?
  public var title: String
  public var synopsis: String
  public var chapterIds: Set<Int>
  public var isPublished: Bool

  public var portraitImageAssetId: Int?
  public var portraitImageAsset: Asset?
  public var landscapeImageAssetId: Int?
  public var landscapeImageAsset: Asset?
  public var squareImageAssetId: Int?
  public var squareImageAsset: Asset?

  required public init(
    storyId: Int,
    userId: Int,
    categoryId: Int? = nil,
    title: String? = nil,
    synopsis: String? = nil,
    chapterIds: Set<Int>? = nil,
    isPublished: Bool,
    portraitImageAssetId: Int? = nil,
    portraitImageAsset: Asset? = nil,
    landscapeImageAssetId: Int? = nil,
    landscapeImageAsset: Asset? = nil,
    squareImageAssetId: Int? = nil,
    squareImageAsset: Asset? = nil
  ) {
    self.storyId = storyId
    self.userId = userId
    self.categoryId = categoryId
    self.title = title ?? ""
    self.synopsis = synopsis ?? ""
    self.chapterIds = chapterIds ?? []
    self.isPublished = isPublished
    self.portraitImageAssetId = portraitImageAssetId
    self.portraitImageAsset = portraitImageAsset
    self.landscapeImageAssetId = landscapeImageAssetId
    self.landscapeImageAsset = landscapeImageAsset
    self.squareImageAssetId = squareImageAssetId
    self.squareImageAsset = squareImageAsset
  }
  
  public init(story: Story) {
    self.storyId = story.storyId
    self.userId = story.userId
    self.categoryId = story.categoryId
    self.title = story.title
    self.synopsis = story.synopsis
    self.chapterIds = story.chapterIds
    self.isPublished = story.isPublished
    self.landscapeImageAssetId = story.landscapeImageAssetId
    self.landscapeImageAsset = story.landscapeImageAsset
    self.portraitImageAssetId = story.portraitImageAssetId
    self.squareImageAssetId = story.squareImageAssetId
    self.squareImageAsset = story.squareImageAsset
    self.portraitImageAsset = story.portraitImageAsset
  }
}

// MARK: - StoryDraft

public struct StoryDraft: Codable {
  public let storyId: Int
  public let userId: Int
  public let currentChapterId: Int

  public init(
    storyId: Int,
    userId: Int,
    currentChapterId: Int
  ) {
    self.storyId = storyId
    self.userId = userId
    self.currentChapterId = currentChapterId
  }

  public func copy(
    storyId: Int? = nil,
    userId: Int? = nil,
    currentChapterId: Int? = nil
  ) -> StoryDraft {
    StoryDraft(
      storyId: storyId ?? self.storyId,
      userId: userId ?? self.userId,
      currentChapterId: currentChapterId ?? self.currentChapterId
    )
  }
}

extension StoryDraft: Equatable {
  public static func == (lhs: StoryDraft, rhs: StoryDraft) -> Bool {
    guard lhs.storyId == rhs.storyId else { return false }
    guard lhs.userId == rhs.userId else { return false }
    guard lhs.currentChapterId == rhs.currentChapterId else { return false }
    return true
  }
}

extension StoryDraft: Hashable {
  public func hash(into hasher: inout Hasher) {
    storyId.hash(into: &hasher)
    userId.hash(into: &hasher)
    currentChapterId.hash(into: &hasher)
  }
}

// MARK: - StoryTimeline

public struct StoryTimeline: Codable {
  public let storyTimelineId: Int
  public let storyId: Int
  public let userId: Int
  public let currentChapterId: Int
  public let createdAt: Date
  public let updatedAt: Date

  public init(
    storyTimelineId: Int,
    storyId: Int,
    userId: Int,
    currentChapterId: Int,
    createdAt: Date,
    updatedAt: Date
  ) {
    self.storyTimelineId = storyTimelineId
    self.storyId = storyId
    self.userId = userId
    self.currentChapterId = currentChapterId
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }

  public func copy(
    storyTimelineId: Int? = nil,
    storyId: Int? = nil,
    userId: Int? = nil,
    currentChapterId: Int? = nil,
    createdAt: Date? = nil,
    updatedAt: Date? = nil
  ) -> StoryTimeline {
    StoryTimeline(
      storyTimelineId: storyTimelineId ?? self.storyTimelineId,
      storyId: storyId ?? self.storyId,
      userId: userId ?? self.userId,
      currentChapterId: currentChapterId ?? self.currentChapterId,
      createdAt: createdAt ?? self.createdAt,
      updatedAt: updatedAt ?? self.updatedAt
    )
  }
}

extension StoryTimeline: Equatable {
  public static func == (lhs: StoryTimeline, rhs: StoryTimeline) -> Bool {
    guard lhs.storyTimelineId == rhs.storyTimelineId else { return false }
    guard lhs.storyId == rhs.storyId else { return false }
    guard lhs.userId == rhs.userId else { return false }
    guard lhs.currentChapterId == rhs.currentChapterId else { return false }
    guard lhs.createdAt == rhs.createdAt else { return false }
    guard lhs.updatedAt == rhs.updatedAt else { return false }
    return true
  }
}

extension StoryTimeline: Hashable {
  public func hash(into hasher: inout Hasher) {
    storyTimelineId.hash(into: &hasher)
    storyId.hash(into: &hasher)
    userId.hash(into: &hasher)
    currentChapterId.hash(into: &hasher)
    createdAt.hash(into: &hasher)
    updatedAt.hash(into: &hasher)
  }
}

// MARK: - User

public struct User: Codable {
  public let userId: Int
  public let firstName: String?
  public let lastName: String?
  public let userName: String?
  public let email: String?
  public let password: String?
  public let biography: String?
  public let avatarAsset: Asset?
  /// transients
  public var userToUser: MutableUserToUser

  public init(
    userId: Int,
    firstName: String? = nil,
    lastName: String? = nil,
    userName: String? = nil,
    email: String? = nil,
    password: String? = nil,
    biography: String? = nil,
    avatarAsset: Asset? = nil,
    userToUser: MutableUserToUser? = nil
  ) {
    self.userId = userId
    self.firstName = firstName
    self.lastName = lastName
    self.userName = userName
    self.email = email
    self.password = password
    self.biography = biography
    self.avatarAsset = avatarAsset
    self.userToUser = userToUser ?? MutableUserToUser(isFollowing: false, isBlocked: false)
  }

  public func copy(
    userId: Int? = nil,
    firstName: String? = nil,
    lastName: String? = nil,
    userName: String? = nil,
    email: String? = nil,
    password: String? = nil,
    biography: String? = nil,
    avatarAsset: Asset? = nil
  ) -> User {
    User(
      userId: userId ?? self.userId,
      firstName: firstName ?? self.firstName,
      lastName: lastName ?? self.lastName,
      userName: userName ?? self.userName,
      email: email ?? self.email,
      password: password ?? self.password,
      biography: biography ?? self.biography,
      avatarAsset: avatarAsset ?? self.avatarAsset
    )
  }
}

extension User: Equatable {
  public static func == (lhs: User, rhs: User) -> Bool {
    guard lhs.userId == rhs.userId else { return false }
    guard compareOptionals(lhs: lhs.firstName, rhs: rhs.firstName, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.lastName, rhs: rhs.lastName, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.userName, rhs: rhs.userName, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.email, rhs: rhs.email, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.password, rhs: rhs.password, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.biography, rhs: rhs.biography, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.avatarAsset, rhs: rhs.avatarAsset, compare: ==) else { return false }
    return true
  }
}

extension User: Hashable {
  public func hash(into hasher: inout Hasher) {
    userId.hash(into: &hasher)
    firstName.hash(into: &hasher)
    lastName.hash(into: &hasher)
    userName.hash(into: &hasher)
    email.hash(into: &hasher)
    password.hash(into: &hasher)
    biography.hash(into: &hasher)
    avatarAsset.hash(into: &hasher)
  }
}
