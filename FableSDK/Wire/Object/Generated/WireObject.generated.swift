// Generated using Sourcery 0.18.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import AppFoundation
import FableSDKEnums
import FableSDKModelObjects
// swiftlint:disable all
import Foundation

// MARK: - WireChapter

public struct WireChapter: Codable {
  public let chapterId: Int?
  public let storyId: Int?
  public let title: String?
  public let index: Int?
  public let messageGroupIds: Set<Int>?
  public let selectedMessageGroupIds: Set<Int>?
  public let previousChapterId: Int?
  public let nextChapterId: Int?
  public let createdAt: String?

  public init(
    chapterId: Int? = nil,
    storyId: Int? = nil,
    title: String? = nil,
    index: Int? = nil,
    messageGroupIds: Set<Int>? = nil,
    selectedMessageGroupIds: Set<Int>? = nil,
    previousChapterId: Int? = nil,
    nextChapterId: Int? = nil,
    createdAt: String? = nil
  ) {
    self.chapterId = chapterId
    self.storyId = storyId
    self.title = title
    self.index = index
    self.messageGroupIds = messageGroupIds
    self.selectedMessageGroupIds = selectedMessageGroupIds
    self.previousChapterId = previousChapterId
    self.nextChapterId = nextChapterId
    self.createdAt = createdAt
  }
}

extension WireChapter: CustomStringConvertible {
  public var description: String { prettyJSONString }
}

extension Chapter {
  public init?(wire: WireChapter) {
    guard let chapterId = wire.chapterId else { return nil }
    guard let storyId = wire.storyId else { return nil }
    guard let createdAt = wire.createdAt?.iso8601Date else { return nil }
    self.init(
      chapterId: chapterId,
      storyId: storyId,
      title: wire.title,
      index: wire.index,
      messageGroupIds: wire.messageGroupIds,
      selectedMessageGroupIds: wire.selectedMessageGroupIds,
      previousChapterId: wire.previousChapterId,
      nextChapterId: wire.nextChapterId,
      createdAt: createdAt
    )
  }

  public func toWire() -> WireChapter {
    WireChapter(
      chapterId: chapterId,
      storyId: storyId,
      title: title,
      index: index,
      messageGroupIds: messageGroupIds,
      selectedMessageGroupIds: selectedMessageGroupIds,
      previousChapterId: previousChapterId,
      nextChapterId: nextChapterId,
      createdAt: createdAt.iso8601String
    )
  }
}

// MARK: - WireCharacter

public struct WireCharacter: Codable {
  public let characterId: Int?
  public let userId: Int?
  public let storyId: Int?
  public let name: String?
  public let colorHexString: String?
  public let messageAlignment: MessageAlignment?
  public let createdAt: String?

  public init(
    characterId: Int? = nil,
    userId: Int? = nil,
    storyId: Int? = nil,
    name: String? = nil,
    colorHexString: String? = nil,
    messageAlignment: MessageAlignment? = nil,
    createdAt: String? = nil
  ) {
    self.characterId = characterId
    self.userId = userId
    self.storyId = storyId
    self.name = name
    self.colorHexString = colorHexString
    self.messageAlignment = messageAlignment
    self.createdAt = createdAt
  }
}

extension WireCharacter: CustomStringConvertible {
  public var description: String { prettyJSONString }
}

extension Character {
  public init?(wire: WireCharacter) {
    guard let characterId = wire.characterId else { return nil }
    guard let userId = wire.userId else { return nil }
    guard let storyId = wire.storyId else { return nil }
    guard let createdAt = wire.createdAt?.iso8601Date else { return nil }
    self.init(
      characterId: characterId,
      userId: userId,
      storyId: storyId,
      name: wire.name,
      colorHexString: wire.colorHexString,
      messageAlignment: wire.messageAlignment,
      createdAt: createdAt
    )
  }

  public func toWire() -> WireCharacter {
    WireCharacter(
      characterId: characterId,
      userId: userId,
      storyId: storyId,
      name: name,
      colorHexString: colorHexString,
      messageAlignment: messageAlignment,
      createdAt: createdAt.iso8601String
    )
  }
}

// MARK: - WireChoice

public struct WireChoice: Codable {
  public let choiceId: Int?
  public let choiceGroupId: Int?
  public let choiceText: String?
  public let createdAt: String?
  public let targetMessageGroupId: Int?

  public init(
    choiceId: Int? = nil,
    choiceGroupId: Int? = nil,
    choiceText: String? = nil,
    createdAt: String? = nil,
    targetMessageGroupId: Int? = nil
  ) {
    self.choiceId = choiceId
    self.choiceGroupId = choiceGroupId
    self.choiceText = choiceText
    self.createdAt = createdAt
    self.targetMessageGroupId = targetMessageGroupId
  }
}

extension WireChoice: CustomStringConvertible {
  public var description: String { prettyJSONString }
}

extension Choice {
  public init?(wire: WireChoice) {
    guard let choiceId = wire.choiceId else { return nil }
    guard let choiceGroupId = wire.choiceGroupId else { return nil }
    guard let createdAt = wire.createdAt?.iso8601Date else { return nil }
    self.init(
      choiceId: choiceId,
      choiceGroupId: choiceGroupId,
      choiceText: wire.choiceText,
      createdAt: createdAt,
      targetMessageGroupId: wire.targetMessageGroupId
    )
  }

  public func toWire() -> WireChoice {
    WireChoice(
      choiceId: choiceId,
      choiceGroupId: choiceGroupId,
      choiceText: choiceText,
      createdAt: createdAt.iso8601String,
      targetMessageGroupId: targetMessageGroupId
    )
  }
}

// MARK: - WireChoiceGroup

public struct WireChoiceGroup: Codable {
  public let choiceGroupId: Int?
  public let modifierId: Int?
  public let modifierKind: ModifierKind?
  public let userId: Int?
  public let storyId: Int?
  public let messageId: Int?
  public let messageGroupId: Int?
  public let choices: [WireChoice]?
  public let createdAt: String?

  public init(
    choiceGroupId: Int? = nil,
    modifierId: Int? = nil,
    modifierKind: ModifierKind? = nil,
    userId: Int? = nil,
    storyId: Int? = nil,
    messageId: Int? = nil,
    messageGroupId: Int? = nil,
    choices: [WireChoice]? = nil,
    createdAt: String? = nil
  ) {
    self.choiceGroupId = choiceGroupId
    self.modifierId = modifierId
    self.modifierKind = modifierKind
    self.userId = userId
    self.storyId = storyId
    self.messageId = messageId
    self.messageGroupId = messageGroupId
    self.choices = choices
    self.createdAt = createdAt
  }
}

extension WireChoiceGroup: CustomStringConvertible {
  public var description: String { prettyJSONString }
}

extension ChoiceGroup {
  public init?(wire: WireChoiceGroup) {
    guard let choiceGroupId = wire.choiceGroupId else { return nil }
    guard let modifierId = wire.modifierId else { return nil }
    guard let modifierKind = wire.modifierKind else { return nil }
    guard let userId = wire.userId else { return nil }
    guard let storyId = wire.storyId else { return nil }
    guard let messageId = wire.messageId else { return nil }
    guard let messageGroupId = wire.messageGroupId else { return nil }
    guard let createdAt = wire.createdAt?.iso8601Date else { return nil }
    self.init(
      choiceGroupId: choiceGroupId,
      modifierId: modifierId,
      modifierKind: modifierKind,
      userId: userId,
      storyId: storyId,
      messageId: messageId,
      messageGroupId: messageGroupId,
      choices: wire.choices?.compactMap { Choice(wire: $0) },
      createdAt: createdAt
    )
  }

  public func toWire() -> WireChoiceGroup {
    WireChoiceGroup(
      choiceGroupId: choiceGroupId,
      modifierId: modifierId,
      modifierKind: modifierKind,
      userId: userId,
      storyId: storyId,
      messageId: messageId,
      messageGroupId: messageGroupId,
      choices: choices.compactMap { $0.toWire() },
      createdAt: createdAt.iso8601String
    )
  }
}

// MARK: - WireConfig

public struct WireConfig: Codable {
  public let configId: Int?
  public let categories: [WireKategory]?
  public let colorHexStrings: [String]?
  public let enableInteractiveStories: Bool?
  public let admins: [String]?
  public let resourceConfig: WireResourceConfig?

  public init(
    configId: Int? = nil,
    categories: [WireKategory]? = nil,
    colorHexStrings: [String]? = nil,
    enableInteractiveStories: Bool? = nil,
    admins: [String]? = nil,
    resourceConfig: WireResourceConfig? = nil
  ) {
    self.configId = configId
    self.categories = categories
    self.colorHexStrings = colorHexStrings
    self.enableInteractiveStories = enableInteractiveStories
    self.admins = admins
    self.resourceConfig = resourceConfig
  }
}

extension WireConfig: CustomStringConvertible {
  public var description: String { prettyJSONString }
}

extension Config {
  public init?(wire: WireConfig) {
    guard let configId = wire.configId else { return nil }
    self.init(
      configId: configId,
      colorHexStrings: wire.colorHexStrings,
      enableInteractiveStories: wire.enableInteractiveStories,
      admins: wire.admins,
      resourceConfig: wire.resourceConfig.flatMap { ResourceConfig(wire: $0) }
    )
  }

  public func toWire() -> WireConfig {
    WireConfig(
      configId: configId,
      colorHexStrings: colorHexStrings,
      enableInteractiveStories: enableInteractiveStories,
      admins: admins,
      resourceConfig: resourceConfig.flatMap { $0.toWire() }
    )
  }
}

// MARK: - WireKategory

public struct WireKategory: Codable {
  public let categoryId: Int?
  public let title: String?
  public let subtitle: String?
  public let stories: [WireStory]?

  public init(
    categoryId: Int? = nil,
    title: String? = nil,
    subtitle: String? = nil,
    stories: [WireStory]? = nil
  ) {
    self.categoryId = categoryId
    self.title = title
    self.subtitle = subtitle
    self.stories = stories
  }
}

extension WireKategory: CustomStringConvertible {
  public var description: String { prettyJSONString }
}

extension Kategory {
  public init?(wire: WireKategory) {
    guard let categoryId = wire.categoryId else { return nil }
    self.init(
      categoryId: categoryId,
      title: wire.title,
      subtitle: wire.subtitle,
      stories: wire.stories?.compactMap { MutableStory(wire: $0) }
      
    )
  }
}

// MARK: - WireMessage

public struct WireMessage: Codable {
  public let messageId: Int?
  public let userId: Int?
  public let storyId: Int?
  public let chapterId: Int?
  public let messageGroupId: Int?
  public let displayIndex: Int?
  public let active: Bool?
  public let text: String?
  public let modifierIds: Set<Int>?
  public let previousMessageId: Int?
  public let nextMessageId: Int?
  public let createdAt: String?
  public let characterId: Int?
  public let character: WireCharacter?
  public let choiceGroup: WireChoiceGroup?

  public init(
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
    createdAt: String? = nil,
    characterId: Int? = nil,
    character: WireCharacter? = nil,
    choiceGroup: WireChoiceGroup? = nil
  ) {
    self.messageId = messageId
    self.userId = userId
    self.storyId = storyId
    self.chapterId = chapterId
    self.messageGroupId = messageGroupId
    self.displayIndex = displayIndex
    self.active = active
    self.text = text
    self.modifierIds = modifierIds
    self.previousMessageId = previousMessageId
    self.nextMessageId = nextMessageId
    self.createdAt = createdAt
    self.characterId = characterId
    self.character = character
    self.choiceGroup = choiceGroup
  }
}

extension WireMessage: CustomStringConvertible {
  public var description: String { prettyJSONString }
}

extension Message {
  public init?(wire: WireMessage) {
    guard let messageId = wire.messageId else { return nil }
    guard let userId = wire.userId else { return nil }
    guard let storyId = wire.storyId else { return nil }
    guard let chapterId = wire.chapterId else { return nil }
    guard let displayIndex = wire.displayIndex else { return nil }
    guard let createdAt = wire.createdAt?.iso8601Date else { return nil }
    self.init(
      messageId: messageId,
      userId: userId,
      storyId: storyId,
      chapterId: chapterId,
      messageGroupId: wire.messageGroupId,
      displayIndex: displayIndex,
      active: wire.active,
      text: wire.text,
      modifierIds: wire.modifierIds,
      previousMessageId: wire.previousMessageId,
      nextMessageId: wire.nextMessageId,
      createdAt: createdAt,
      characterId: wire.characterId,
      character: wire.character.flatMap { MutableCharacter(wire: $0) },
      choiceGroup: wire.choiceGroup.flatMap { ChoiceGroup(wire: $0) }
    )
  }

  public func toWire() -> WireMessage {
    WireMessage(
      messageId: messageId,
      userId: userId,
      storyId: storyId,
      chapterId: chapterId,
      messageGroupId: messageGroupId,
      displayIndex: displayIndex,
      active: active,
      text: text,
      modifierIds: modifierIds,
      previousMessageId: previousMessageId,
      nextMessageId: nextMessageId,
      createdAt: createdAt.iso8601String,
      characterId: characterId,
      character: character.flatMap { $0.toWire() },
      choiceGroup: choiceGroup.flatMap { $0.toWire() }
    )
  }
}

// MARK: - WireMessageGroup

public struct WireMessageGroup: Codable {
  public let messageGroupId: Int?
  public let storyId: Int?
  public let chapterId: Int?
  public let userId: Int?
  public let messageGroupTitle: String?
  public let index: Int?
  public let previousMessageGroupId: Int?
  public let nextMessageGroupId: Int?
  public let sourceMessageId: Int?
  public let createdAt: String?

  public init(
    messageGroupId: Int? = nil,
    storyId: Int? = nil,
    chapterId: Int? = nil,
    userId: Int? = nil,
    messageGroupTitle: String? = nil,
    index: Int? = nil,
    previousMessageGroupId: Int? = nil,
    nextMessageGroupId: Int? = nil,
    sourceMessageId: Int? = nil,
    createdAt: String? = nil
  ) {
    self.messageGroupId = messageGroupId
    self.storyId = storyId
    self.chapterId = chapterId
    self.userId = userId
    self.messageGroupTitle = messageGroupTitle
    self.index = index
    self.previousMessageGroupId = previousMessageGroupId
    self.nextMessageGroupId = nextMessageGroupId
    self.sourceMessageId = sourceMessageId
    self.createdAt = createdAt
  }
}

extension WireMessageGroup: CustomStringConvertible {
  public var description: String { prettyJSONString }
}

extension MessageGroup {
  public init?(wire: WireMessageGroup) {
    guard let messageGroupId = wire.messageGroupId else { return nil }
    guard let storyId = wire.storyId else { return nil }
    guard let chapterId = wire.chapterId else { return nil }
    guard let userId = wire.userId else { return nil }
    guard let createdAt = wire.createdAt?.iso8601Date else { return nil }
    self.init(
      messageGroupId: messageGroupId,
      storyId: storyId,
      chapterId: chapterId,
      userId: userId,
      messageGroupTitle: wire.messageGroupTitle,
      index: wire.index,
      previousMessageGroupId: wire.previousMessageGroupId,
      nextMessageGroupId: wire.nextMessageGroupId,
      sourceMessageId: wire.sourceMessageId,
      createdAt: createdAt
    )
  }

  public func toWire() -> WireMessageGroup {
    WireMessageGroup(
      messageGroupId: messageGroupId,
      storyId: storyId,
      chapterId: chapterId,
      userId: userId,
      messageGroupTitle: messageGroupTitle,
      index: index,
      previousMessageGroupId: previousMessageGroupId,
      nextMessageGroupId: nextMessageGroupId,
      sourceMessageId: sourceMessageId,
      createdAt: createdAt.iso8601String
    )
  }
}

// MARK: - WireResourceConfig

public struct WireResourceConfig: Codable {
  public init(
  ) {}
}

extension WireResourceConfig: CustomStringConvertible {
  public var description: String { prettyJSONString }
}

extension ResourceConfig {
  public init?(wire: WireResourceConfig) {
    self.init(
    )
  }

  public func toWire() -> WireResourceConfig {
    WireResourceConfig(
    )
  }
}

// MARK: - WireStoryDraft

public struct WireStoryDraft: Codable {
  public let storyId: Int?
  public let userId: Int?
  public let currentChapterId: Int?

  public init(
    storyId: Int? = nil,
    userId: Int? = nil,
    currentChapterId: Int? = nil
  ) {
    self.storyId = storyId
    self.userId = userId
    self.currentChapterId = currentChapterId
  }
}

extension WireStoryDraft: CustomStringConvertible {
  public var description: String { prettyJSONString }
}

extension StoryDraft {
  public init?(wire: WireStoryDraft) {
    guard let storyId = wire.storyId else { return nil }
    guard let userId = wire.userId else { return nil }
    guard let currentChapterId = wire.currentChapterId else { return nil }
    self.init(
      storyId: storyId,
      userId: userId,
      currentChapterId: currentChapterId
    )
  }

  public func toWire() -> WireStoryDraft {
    WireStoryDraft(
      storyId: storyId,
      userId: userId,
      currentChapterId: currentChapterId
    )
  }
}

// MARK: - WireStoryTimeline

public struct WireStoryTimeline: Codable {
  public let storyTimelineId: Int?
  public let storyId: Int?
  public let userId: Int?
  public let currentChapterId: Int?
  public let createdAt: String?
  public let updatedAt: String?

  public init(
    storyTimelineId: Int? = nil,
    storyId: Int? = nil,
    userId: Int? = nil,
    currentChapterId: Int? = nil,
    createdAt: String? = nil,
    updatedAt: String? = nil
  ) {
    self.storyTimelineId = storyTimelineId
    self.storyId = storyId
    self.userId = userId
    self.currentChapterId = currentChapterId
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}

extension WireStoryTimeline: CustomStringConvertible {
  public var description: String { prettyJSONString }
}

extension StoryTimeline {
  public init?(wire: WireStoryTimeline) {
    guard let storyTimelineId = wire.storyTimelineId else { return nil }
    guard let storyId = wire.storyId else { return nil }
    guard let userId = wire.userId else { return nil }
    guard let currentChapterId = wire.currentChapterId else { return nil }
    guard let createdAt = wire.createdAt?.iso8601Date else { return nil }
    guard let updatedAt = wire.updatedAt?.iso8601Date else { return nil }
    self.init(
      storyTimelineId: storyTimelineId,
      storyId: storyId,
      userId: userId,
      currentChapterId: currentChapterId,
      createdAt: createdAt,
      updatedAt: updatedAt
    )
  }

  public func toWire() -> WireStoryTimeline {
    WireStoryTimeline(
      storyTimelineId: storyTimelineId,
      storyId: storyId,
      userId: userId,
      currentChapterId: currentChapterId,
      createdAt: createdAt.iso8601String,
      updatedAt: updatedAt.iso8601String
    )
  }
}

// MARK: - WireUser

public struct WireUser: Codable {
  public let userId: Int?
  public let firstName: String?
  public let lastName: String?
  public let userName: String?
  public let email: String?
  public let password: String?
  public let biography: String?
  public let avatarAsset: WireAsset?

  /// transients
  public let userToUser: WireUserToUser?

  public init(
    userId: Int? = nil,
    firstName: String? = nil,
    lastName: String? = nil,
    userName: String? = nil,
    email: String? = nil,
    password: String? = nil,
    biography: String? = nil,
    avatarAsset: WireAsset? = nil,
    userToUser: WireUserToUser? = nil
  ) {
    self.userId = userId
    self.firstName = firstName
    self.lastName = lastName
    self.userName = userName
    self.email = email
    self.password = password
    self.biography = biography
    self.avatarAsset = avatarAsset
    self.userToUser = userToUser
  }
}

extension WireUser: CustomStringConvertible {
  public var description: String { prettyJSONString }
}

extension User {
  public init?(wire: WireUser) {
    guard let userId = wire.userId else { return nil }
    self.init(
      userId: userId,
      firstName: wire.firstName,
      lastName: wire.lastName,
      userName: wire.userName,
      email: wire.email,
      password: wire.password,
      biography: wire.biography,
      avatarAsset: wire.avatarAsset.flatMap { Asset(wire: $0) },
      userToUser: wire.userToUser.flatMap(MutableUserToUser.init(wire:))
    )
  }

  public func toWire() -> WireUser {
    WireUser(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      userName: userName,
      email: email,
      password: password,
      biography: biography,
      avatarAsset: avatarAsset.flatMap { $0.toWire() }
    )
  }
}
