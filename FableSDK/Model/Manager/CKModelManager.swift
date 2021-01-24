//
//  CKModelManager.swift
//  Fable
//
//  Created by Andrew Aquino on 12/14/19.
//

import AppFoundation
import FableSDKEnums
import FableSDKModelObjects
import FableSDKResourceManagers
import FableSDKResourceTargets
import FableSDKWireObjects
import ReactiveSwift
import UIKit
import Firebolt


public protocol CKModelManagerWriteOnly {
  var onUpdate: Signal<Void, Never> { get }

  func refreshConfig()

  func repairMessageLinks(messageIds: Set<Int>)
  
  // MARK: Stories

  func refreshStory()
  func saveStory()
  func uploadStoryImage(_ image: UIImage, forKey key: ImageKey, _ callback: @escaping () -> Void)
  func publishStory()
  func unpublishStory()
  func removeStory()

  // MARK: Chapters

  func refreshChapters()
  
  // MARK: Message Groups

  func appendNewMessageGroup()
  func deleteMessageGroup(messageGroupId: Int)
  func refreshMessageGroups()
  func saveMessageGroups()
  func removeMessageGroups(messageGroupIds: Set<Int>)

  func updateMessageGroup(messageGroupId: Int)
  
  // MARK: MESSAGES

  func appendNewMessage(
    presentedMessageIds: [Int]
  )
  func removeMessage(messageId: Int)
  func removeMessages(messageIds: Set<Int>)
  func updateMessage(messageId: Int, text: String?, displayIndex: Int?, active: Bool?, characterId: Int?)

  // MARK: Characters

  func appendNewCharacter(colorHexString: String)
  func removeCharacter(characterId: Int)
  func updateCharacter(
    characterId: Int,
    name: String?,
    colorHexString: String?,
    messageAlignment: MessageAlignment?
  )
  func refreshCharacters()

  // MARK: Modifiers

  func attachCharacterToMessage(characterId: Int, messageId: Int)
  func detachCharacterFromMessage(characterId: Int, messageId: Int)

  // MARK: Choices
  
  func attachChoiceGroup(
    userId: Int,
    chapterId: Int,
    messageGroupId: Int,
    toMessageId: Int
  ) -> ChoiceGroup?

  func detachChoiceGroup(modifierId: Int, fromMessageId: Int)
  
  func getModel() -> DataStore
}


public class CKModelManager {
  internal let globalQueue: DispatchQueue

  // MARK: - Properties

  internal var removedStory: Bool = false
  internal let minimumProvisonedMessagesCount = 3

  // MARK: - Observers

  public let onUpdate: Signal<Void, Never>
  private let onUpdateObserver: Signal<Void, Never>.Observer

  // MARK: - Model

  private var model: DataStore
  private let sortedModel: SortedModel
  private let choiceModel: ChoiceModelWriteOnly
  private var selector: CKSelector
  
  // MARK: - Dependencies

  private let networkManager: NetworkManager
  private let authManager: AuthManager
  private let eventManager: EventManager
  private let stateManager: StateManager
  private let resourceManager: ResourceManager

  public init(
    networkManager: NetworkManager,
    authManager: AuthManager,
    eventManager: EventManager,
    stateManager: StateManager,
    resourceManager: ResourceManager,
    model: DataStore,
    sortedModel: SortedModel,
    choiceModel: ChoiceModel,
    selector: CKSelector,
    globalQueue: DispatchQueue
  ) {
    self.model = model
    self.globalQueue = globalQueue
    self.networkManager = networkManager
    self.authManager = authManager
    self.eventManager = eventManager
    self.stateManager = stateManager
    self.resourceManager = resourceManager
    self.sortedModel = sortedModel
    self.selector = selector
    self.choiceModel = choiceModel
    (self.onUpdate, self.onUpdateObserver) = Signal<Void, Never>.pipe()
    
    self.setSelected(.chapterId(model.selectedChapterId))
  }

  public func modifyDataStore(_ closure: @escaping (inout DataStore) -> Void) {
    globalQueue.sync { closure(&model) }
  }
  
  public func getModel() -> DataStore {
    globalQueue.sync { model }
  }
  
  internal func publishState() {
    onUpdateObserver.send(value: ())
  }
}


extension CKModelManager {
  public func refreshConfig() {
    resourceManager.getConfig()
      .startWithResult { [weak self] result in
        switch result {
        case let .failure(error):
          print(error)
        case let .success(wire):
          guard let wire = wire else { return }
          if let colorHexStrings = wire.colorHexStrings {
            self?.modifyDataStore { dataStore in
              dataStore.colorHexStrings = colorHexStrings
            }
          }
          if let categories = wire.categories?.compactMap({ Kategory(wire: $0) }) {
            self?.modifyDataStore { dataStore in
              dataStore.categories = categories.indexed(by: \.categoryId)
            }
            self?.publishState()
          }
        }
      }
  }

  public func repairMessageLinks(messageIds: Set<Int>) {
    onUpdateObserver.send(value: ())
  }

  // MARK: - STORY

  public func refreshStory() {
//    resourceManager.refreshStory(storyId: story.storyId)
//      .startWithResult { [weak self] result in
//        switch result {
//        case let .failure(error):
//          print(error)
//        case let .success(wire):
//          self.onUpdateObserver.send(value: ())
//        }
//      }
  }

  public func saveStory() {
    resourceManager.updateStory(
      storyId: story.storyId,
      categoryId: story.categoryId,
      title: story.title,
      synopsis: story.synopsis
    ).start()
  }

  public func uploadStoryImage(_ image: UIImage, forKey key: ImageKey, _ callback: @escaping () -> Void) {
    guard let data = image.pngData() else { return }
    resourceManager.uploadAsset(
      userId: model.userId,
      asset: data,
      fileName: "story_\(model.story.storyId)_\(key.rawValue).png",
      tags: [
        "story_\(model.story.storyId)",
        key.rawValue
    ]).flatMap(.latest) { [weak self] asset -> SignalProducer<Asset?, Exception> in
      guard let self = self, let asset = asset else { return .empty }
      switch key {
      case .landscape:
        return self.resourceManager.updateStory(
          storyId: self.model.story.storyId,
          landscapeImageAssetId: asset.assetId
        ).map { _ in asset }
      case .square:
        return self.resourceManager.updateStory(
          storyId: self.model.story.storyId,
          squareImageAssetId: asset.assetId
        ).map { _ in asset }
      }
    }.startWithResult { _ in
    }
  }

  public func publishStory() {
    resourceManager.updateStory(
      storyId: model.story.storyId,
      published: true
    ).start()
  }

  public func unpublishStory() {
    resourceManager.updateStory(
      storyId: model.story.storyId,
      published: false
    ).start()
  }

  public func removeStory() {
    resourceManager.removeStory(storyId: story.storyId)
      .startWithResult { [weak self] result in
        switch result {
        case .failure:
          break
        case .success:
          self?.removedStory = true
          self?.publishState()
        }
      }
  }

  // MARK: - EPISODE

  public func refreshChapter(chapterId: Int) {
    resourceManager.refreshChapter(chapterId: chapterId)
      .startWithResult { [weak self] result in
        switch result {
        case let .failure(error):
          print(error)
        case let .success(wire):
          guard let wire = wire, let chapter = Chapter(wire: wire) else { return }
          self?.modifyDataStore { dataStore in
            dataStore.chapters[chapter.chapterId] = chapter
          }
          self?.publishState()
        }
      }
  }

  public func refreshChapters() {
    resourceManager.refreshChapters(storyId: story.storyId)
      .startWithResult { [weak self] result in
        switch result {
        case let .failure(error):
          print(error)
        case let .success(wire):
          let chapters = wire.compactMap { Chapter(wire: $0) }
          self?.modifyDataStore { dataStore in
            dataStore.chapters = chapters.indexed(by: \.chapterId)
          }
          self?.publishState()
        }
      }
  }

  // MARK: - MESSAGE GROUP

  public func appendNewMessageGroup() {}

  public func deleteMessageGroup(messageGroupId: Int) {}

  public func refreshMessageGroups(chapterId: Int) {
    resourceManager.refreshMessageGroups(storyId: story.storyId, chapterId: chapterId)
      .startWithResult { result in
        switch result {
        case let .failure(error):
          print(error)
        case .success:
          break
        }
      }
  }

  public func refreshMessageGroups() {
    resourceManager.refreshMessageGroups(storyId: story.storyId)
      .startWithResult { result in
        switch result {
        case let .failure(error):
          print(error)
        case .success:
          break
        }
      }
  }

  public func saveMessageGroups() {}

  public func removeMessageGroups(messageGroupIds: Set<Int>) {}

  public func updateMessageGroup(messageGroupId: Int) {}

  // MARK: - MESSAGE

  public func appendNewMessage(
    previousMessageId: Int?,
    selectedMessageId: Int?,
    nextMessageId: Int?,
    textInput: String,
    characterId: Int?
  ) {
    guard let chapterId = selectedChapterId else { return }

    let previousMessage: Message? = {
      if let selectedMessageId = selectedMessageId {
        return fetchMessage(messageId: selectedMessageId)
      } else if let previousMessageId = previousMessageId {
        return fetchMessage(messageId: previousMessageId)
      }
      return nil
    }()
    
    let nextMessage = nextMessageId.flatMap(fetchMessage(messageId:))

    // create a new inactive message whenever we reach a minimum
    let newMessagesCount = fetchInactiveMessageCount()
    for _ in 0..<max(minimumProvisonedMessagesCount - newMessagesCount, 0) {
      createNewMessage(
        chapterId: chapterId,
        previousMessageId: nil,
        nextMessageId: nil,
        characterId: nil,
        active: false,
        text: ""
      )
    }

    if let newMessage = fetchInactiveMessages() {
      
      if let characterId = characterId {
        attachCharacterToMessage(characterId: characterId, messageId: newMessage.messageId)
      }
      
      networkManager.request(
        UpdateMessageDisplayIndex(messageId: newMessage.messageId),
        parameters: .init(
          previousMessageId: previousMessage?.messageId,
          nextMessageId: nextMessage?.messageId
        )
      ).start()
      
      let displayIndex = calculateDisplayIndex(
        previousMessage: previousMessage,
        nextMessage: nextMessage
      )

      networkManager.request(
        UpdateMessage(messageId: newMessage.messageId),
        parameters: .init(
          text: textInput,
          active: true
        )
      ).start()

      updateMessage(
        messageId: newMessage.messageId,
        text: textInput,
        displayIndex: displayIndex,
        nextMessageId: nextMessage?.messageId,
        active: true
      )
      
      self.setSelected(.message(newMessage.messageId))

    } else {
      createNewMessage(
        chapterId: chapterId,
        previousMessageId: previousMessage?.messageId,
        nextMessageId: nextMessage?.messageId,
        characterId: characterId,
        active: true,
        text: textInput
      )
    }
  }
  
  private func calculateDisplayIndex(
    previousMessage: Message?,
    nextMessage: Message?
  ) -> Int {
    if let previousMessage = previousMessage, nextMessage == nil {
      return previousMessage.displayIndex + 10000
    } else if previousMessage == nil, let nextMessage = nextMessage {
      return nextMessage.displayIndex / 2
    } else if let previousMessage = previousMessage, let nextMessage = nextMessage {
      return (previousMessage.displayIndex + nextMessage.displayIndex) / 2
    }
    return 10000
  }
  
  private func createNewMessage(
    chapterId: Int,
    previousMessageId: Int?,
    nextMessageId: Int?,
    characterId: Int?,
    active: Bool,
    text: String
  ) {
  }

  public func removeMessage(previousMessageId: Int?, messageId: Int) {
  }

  public func removeMessages(messageIds: Set<Int>) {
    modifyDataStore { dataStore in
      dataStore.messages = dataStore.messages.filter { key, _ in !messageIds.contains(key) }
    }
  }

  public func updateMessage(
    messageId: Int,
    text: String? = nil,
    displayIndex: Int? = nil,
    nextMessageId: Int? = nil,
    active: Bool? = nil,
    characterId: Int? = nil
  ) {
  }

  // MARK: - CHARACTER

  public func appendNewCharacter(
    colorHexString: String
  ) {
    let messageAlignment: MessageAlignment = fetchCharacters().count == 1 ? .trailing : .leading
    resourceManager.appendNewCharacter(
      storyId: model.story.storyId,
      userId: model.userId,
      name: "",
      colorHexString: colorHexString,
      messageAlignment: messageAlignment
    ).startWithResult { [weak self] result in
      switch result {
      case .failure:
        break
      case let .success(wire):
        guard let wire = wire, let character = MutableCharacter(wire: wire) else { return }
        self?.modifyDataStore { dataStore in
          dataStore.characters[character.characterId] = character
        }
      }
      self?.publishState()
    }
  }

  public func removeCharacter(characterId: Int) {
    modifyDataStore { dataStore in
      dataStore.characters[characterId] = nil
    }
    onUpdateObserver.send(value: ())
    resourceManager.removeCharacter(storyId: story.storyId, characterId: characterId).start()
  }

  public func refreshCharacters() {
    resourceManager.refreshCharacters(storyId: story.storyId).startWithResult { [weak self] result in
      switch result {
      case .failure:
        break
      case let .success(wires):
        let characters = wires.compactMap(MutableCharacter.init)
        self?.modifyDataStore { dataStore in
          dataStore.characters = characters.indexed(by: \.characterId)
        }
        self?.publishState()
      }
    }
  }
  
  public func updateCharacter(
    characterId: Int,
    name: String?,
    colorHexString: String?,
    messageAlignment: MessageAlignment?
  ) {
    
    // Update the Data Store first, to give a better
    // visual experience for the user

    // then, update the db
    resourceManager.updateCharacter(
      characterId: characterId,
      name: name,
      colorHexString: colorHexString,
      messageAlignment: messageAlignment
    ).startWithResult { [weak self] result in
      switch result {
      case .failure:
        break
      case .success:
        self?.publishState()
      }
    }
  }

  public func attachCharacterToMessage(characterId: Int, messageId: Int) {
    networkManager.request(
      AttachCharacterToMessage(messageId: messageId),
      parameters: AttachCharacterToMessage.RequestBody(characterId: characterId)
    ).start()
//    modifyDataStore { store in
//      store.messages[messageId] = store.messages[messageId]?.copy(characterId: characterId)
//    }
    self.publishState()
  }

  public func detachCharacterFromMessage(characterId: Int, messageId: Int) {
    networkManager.request(
      AttachCharacterToMessage(messageId: messageId),
      parameters: AttachCharacterToMessage.RequestBody(characterId: nil)
    ).start()
//    modifyDataStore { store in
//      store.messages[messageId] = store.messages[messageId]?.copy(characterId: -1)
//    }
    self.publishState()
  }

  // MARK: - Choice

  public func attachChoiceGroup(
    userId: Int,
    chapterId: Int,
    messageGroupId: Int,
    toMessageId: Int
  ) -> ChoiceGroup? {
    nil
  }

  public func detachChoiceGroup(modifierId: Int, fromMessageId: Int) {
    // fetch
//    guard let choiceGroup = fetchChoiceGroup(modifierId: modifierId) else { return }
//    guard var fromMessage = fetchMessage(messageId: fromMessageId) else { return }

    // modify
//    fromMessage = fromMessage.copy(
//      modifierIds: fromMessage.modifierIds.removing(choiceGroup.modifierId)
//    )
//    remove(modifierId: choiceGroup.modifierId)

    // update remote
//    resourceManager.detachModifiers(messageId: fromMessageId, modifierIds: [choiceGroup.modifierId]).start()

    // publish
//    onUpdateObserver.send(value: ())
  }
}


extension CKModelManager: CKModelReadOnly {
  public var story: Story {
    globalQueue.sync { model.story }
  }
  
  public func fetchCategory(categoryId: Int) -> Kategory? {
    globalQueue.sync { model.categories[categoryId] }
  }
  
  public func fetchCategories() -> [Kategory] {
    globalQueue.sync { model.fetchCategories() }
  }
  
  public func fetchChapter(chapterId: Int) -> Chapter? {
    globalQueue.sync { model.chapters[chapterId] }
  }
  
  public func fetchChapters(chapterIds: [Int]) -> [Chapter] {
    globalQueue.sync { chapterIds.compactMap { model.chapters[$0] } }
  }
  
  public func fetchChapters() -> [Chapter] {
    globalQueue.sync { model.fetchChapters() }
  }
  
  public func fetchMessageGroup(messageGroupId: Int) -> MessageGroup? {
    globalQueue.sync { model.messageGroups[messageGroupId] }
  }
  
  public func fetchMessageGroups(messageGroupIds: [Int]) -> [MessageGroup] {
    globalQueue.sync { messageGroupIds.compactMap { model.messageGroups[$0] } }
  }
  
  public func fetchMessageGroups(messageGroupIds: Set<Int>) -> [MessageGroup] {
    globalQueue.sync { messageGroupIds.compactMap { model.messageGroups[$0] } }
  }
  
  public func fetchMessageGroups() -> [MessageGroup] {
    globalQueue.sync { model.fetchMessageGroups() }
  }
  
  public func fetchInactiveMessages() -> Message? {
    globalQueue.sync { model.fetchMessages().first(where: \.active.negated) }
  }
  
  public func fetchInactiveMessageCount() -> Int {
    globalQueue.sync { model.fetchMessages().filter(\.active.negated) }.count
  }

  public func fetchMessage(messageId: Int) -> Message? {
    globalQueue.sync { model.messages[messageId] }
  }
  
  public func fetchMessages(messageIds: [Int]) -> [Message] {
    globalQueue.sync { messageIds.compactMap { model.messages[$0] } }
  }
  
  public func fetchMessages(messageIds: Set<Int>) -> [Message] {
    globalQueue.sync { messageIds.compactMap { model.messages[$0] } }
  }

  public func fetchMessages(messageGroupId: Int) -> [Message] {
    globalQueue.sync { model.fetchMessages().filter { $0.messageGroupId == messageGroupId } }
  }
  
  public func fetchMessages() -> [Message] {
    globalQueue.sync { model.fetchMessages().filter(\.active) }
  }
  
  public func fetchCharacter(messageId: Int) -> Character? {
    let message = fetchMessage(messageId: messageId)
    guard let characterId = message?.characterId else { return nil }
    return globalQueue.sync { model.characters[characterId] }
  }
  
  public func fetchCharacter(characterId: Int) -> Character? {
    globalQueue.sync { model.characters[characterId] }
  }
  
  public func fetchCharacter(modifierId: Int) -> Character? {
    nil
  }
  
  public func fetchCharacterId(messageId: Int) -> Int? {
    let message = fetchMessage(messageId: messageId)
    return message?.characterId
  }
  
  public func fetchCharacters(characterIds: Set<Int>) -> [Character] {
    globalQueue.sync { characterIds.compactMap { model.characters[$0] } }
  }
  
  public func fetchCharacters() -> [Character] {
    globalQueue.sync { model.fetchCharacters() }
  }
  
  public func fetchChoice(choiceId: Int) -> Choice? {
    nil
  }
  
  public func fetchChoiceGroup(modifierId: Int) -> ChoiceGroup? {
    nil
  }
  
  public func fetchChoiceGroup(choiceGroupId: Int) -> ChoiceGroup? {
    nil
  }
  
  public func fetchChoiceGroups() -> [ChoiceGroup] {
    []
  }
  
  public func fetchColorHexStrings() -> [String] {
    globalQueue.sync { model.colorHexStrings }
  }
}


extension CKModelManager: CKSelectorReadOnly {
  public var selectedChapterId: Int? {
    globalQueue.sync { selector.selectedChapterId }
  }
  
  public var selectedMessageGroupId: Int? {
    globalQueue.sync { selector.selectedMessageGroupId }
  }
  
  public var selectedMessageGroupIds: [Int] {
    globalQueue.sync { selector.selectedMessageGroupIds }
  }
  
  public var selectedCharacterId: Int? {
    globalQueue.sync { selector.selectedCharacterId }
  }
  
  public var selectedMessageId: Int? {
    globalQueue.sync { selector.selectedMessageId }
  }
  
  public var selectedModifierId: Int? {
    globalQueue.sync { selector.selectedModifierId }
  }
  
  public var firstResponder: UIResponder? {
    globalQueue.sync { selector.firstResponder }
  }
  
  public var focusKind: CKSelector.FocusKind {
    globalQueue.sync { selector.focusKind }
  }
  
  public var selectedChoiceIds: Set<Int> {
    globalQueue.sync { selector.selectedChoiceIds }
  }
  
  public var selectedChoiceId: Int? {
    globalQueue.sync { selector.selectedChoiceId }
  }
}


extension CKModelManager: CKSelectorWriteOnly {
  public func setFirstResponder(_ responder: UIResponder?) {
    globalQueue.sync { selector.setFirstResponder(responder) }
  }
  
  public func setFocus(_ focusKind: CKSelector.FocusKind) {
    globalQueue.sync { selector.setFocus(focusKind) }
  }
  
  public func unsetFocus() {
    globalQueue.sync { selector.unsetFocus() }
  }
  
  public func maybeSetFocus(_ focusKind: CKSelector.FocusKind) -> Bool {
    globalQueue.sync { selector.maybeSetFocus(focusKind) }
  }
  
  public func setSelected(_ selectionKind: CKSelector.SelectionKind) {
    globalQueue.sync { selector.setSelected(selectionKind) }
  }
  
  public func setDeselected(_ deselectionKind: CKSelector.DeselectionKind) {
    globalQueue.sync { selector.setDeselected(deselectionKind) }
  }
}

public extension Bool {
  var negated: Bool { !self }
}
