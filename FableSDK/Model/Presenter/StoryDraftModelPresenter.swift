//
//  StoryDraftModelPresenter.swift
//  FableSDKModelPresenters
//
//  Created by Andrew Aquino on 11/28/20.
//

import Foundation
import AppFoundation
import FableSDKEnums
import FableSDKResolver
import FableSDKModelObjects
import FableSDKModelManagers
import Combine

public struct StoryDraftModelPresenterBuilder {
  public static func make(resolver: FBSDKResolver, context: StoryDraftModelPresenterContext) -> StoryDraftModelPresenter {
    StoryDraftModelPresenterImpl(resolver: resolver, context: context)
  }
}

public protocol StoryDraftModelPresenter {
  func loadInitialData()

  func fetchModel() -> StoryDraftModel?
  
  /// Story
  
  func updateStory(parameters: UpdateStoryParameters)
  func uploadPortraitAssetForStory(data: Data)
  func uploadLandscapeAssetForStory(data: Data)
  func deleteStory() -> AnyPublisher<Void, Exception> 

  /// Messages
  
  func reloadMessages()
  func insertMessage(text: String, previousMessageId: Int?, nextMessageId: Int?, selectedCharacterId: Int?)
  func removeMessage(messageId: Int)
  func updateMessage(messageId: Int, text: String?, displayIndex: Int?)
  func setCharacterForMessage(messageId: Int, characterId: Int?)

  /// Characters
  
  func reloadCharacters()
  func insertCharacter(_ character: Character)
  func removeCharacter(_ characterId: Int)
  func updateCharacter(_ characterId: Int, name: String?, colorHexString: String?, messageAlignment: MessageAlignment?)

  /// Editor
  
  func setEditMode(_ editMode: StoryDraftEditMode)
}

public enum StoryDraftModelPresenterContext {
  case newStory
  case recentStory
  case existingStory(storyId: Int)
}

private class StoryDraftModelPresenterImpl: StoryDraftModelPresenter {
  private let storyDraftManager: StoryDraftManager
  private let storyManager: StoryManager
  private let chapterManager: ChapterManager
  private let messageManager: MessageManager
  private let characterManager: CharacterManager
  private let eventManager: EventManager
  private let configManager: ConfigManager
  private let categoryManager: CategoryManager
  private let assetManager: AssetManager

  private var model: MutableStoryDraftModel?
  
  public var editMode: StoryDraftEditMode = .normal
  private let context: StoryDraftModelPresenterContext

  public init(resolver: FBSDKResolver, context: StoryDraftModelPresenterContext) {
    self.storyDraftManager = resolver.get()
    self.storyManager = resolver.get()
    self.chapterManager = resolver.get()
    self.messageManager = resolver.get()
    self.characterManager = resolver.get()
    self.eventManager = resolver.get()
    self.configManager = resolver.get()
    self.categoryManager = resolver.get()
    self.assetManager = resolver.get()
    self.context = context
  }
  
  public func loadInitialData() {
    switch context {
    case let .existingStory(storyId):
      self.loadInitialData(storyId: storyId)
    case .newStory:
      storyDraftManager.createStoryDraft()
        .sinkDisposed(receiveCompletion: nil) { [weak self] storyDraft in
          guard let storyDraft = storyDraft else { return }
          self?.loadInitialData(storyDraft: storyDraft)
        }
    case .recentStory:
      storyDraftManager.fetchLatestOrCreateStoryDraft()
        .sinkDisposed(receiveCompletion: nil) { [weak self] storyDraft in
          self?.loadInitialData(storyDraft: storyDraft)
        }
    }
  }
  
  private func loadInitialData(storyId: Int) {
    if
      let storyDraft = storyDraftManager.fetchByStoryId(storyId: storyId),
      let story = storyManager.fetchById(storyId: storyDraft.storyId),
      let chapter = chapterManager.fetchById(chapterId: storyDraft.currentChapterId)
    {
      let characters = characterManager.listCachedByStoryId(storyId: story.storyId)
      let messages = messageManager.listCachedByChapterId(chapterId: chapter.chapterId)
      self.model = MutableStoryDraftModel(
        story: story,
        currentChapter: chapter,
        messages: messages,
        characters: characters,
        colorHexString: []
      )
      self.eventManager.sendEvent(StoryDraftModelPresenterEvent.didLoadInitialData)
    }
    storyDraftManager.refreshStoryDraft(storyId: storyId)
      .sinkDisposed(receiveCompletion: nil) { [weak self] storyDraft in
        self?.loadInitialData(storyDraft: storyDraft)
      }
  }
  
  private func loadInitialData(storyDraft: StoryDraft) {
    let storyData = Publishers.CombineLatest4(
      storyManager.findById(storyId: storyDraft.storyId),
      chapterManager.findById(chapterId: storyDraft.currentChapterId),
      messageManager.listByChapterId(storyDraft.currentChapterId),
      characterManager.listByStoryId(storyDraft.storyId)
    ).eraseToAnyPublisher()
    let configData = configManager.refreshConfigV2()
    Publishers.CombineLatest(
      storyData,
      configData
    ).eraseToAnyPublisher().sinkDisposed(receiveCompletion: nil) { [weak self] storyData, config in
      let (_story, _chapter, messages, characters) = storyData
      guard let story = _story, let chapter = _chapter, let config = config else { return }
      self?.model = MutableStoryDraftModel(
        story: story,
        currentChapter: chapter,
        messages: messages,
        characters: characters,
        colorHexString: config.colorHexStrings
      )
      self?.eventManager.sendEvent(StoryDraftModelPresenterEvent.didRefreshCharacters)
      self?.eventManager.sendEvent(StoryDraftModelPresenterEvent.didLoadInitialData)
    }
  }
  
  func fetchModel() -> StoryDraftModel? { model }
  
  func updateStory(parameters: UpdateStoryParameters) {
    guard let model = self.model else { return }
    self.storyManager.updatebyId(
      storyId: model.fetchStory().storyId,
      parameters: parameters
    ).sinkDisposed(receiveCompletion: nil) { [weak self] in
      if let story = self?.model?.fetchStory() as? MutableStory {
        parameters.apply(story: story)
      }
      self?.eventManager.sendEvent(StoryDraftModelPresenterEvent.didUpdateStory(storyId: model.fetchStory().storyId))
    }
  }
  
  func uploadPortraitAssetForStory(data: Data) {
    guard let storyId = fetchModel()?.fetchStory().storyId else { return }
    let fileName = "story_\(storyId)_portrait_image.png"
    self.assetManager.uploadAsset(
      asset: data,
      fileName: fileName,
      tags: [fileName]
    ).sinkDisposed(receiveCompletion: nil) { [weak self] asset in
      guard let asset = asset else { return }
      self?.model?.updateStory({ story in
        story.portraitImageAsset = asset
      })
      self?.updateStory(parameters: UpdateStoryParameters(portraitImageAssetId: asset.assetId))
    }
  }
  
  func uploadLandscapeAssetForStory(data: Data) {
    guard let storyId = fetchModel()?.fetchStory().storyId else { return }
    let fileName = "story_\(storyId)_landscape_image.png"
    self.assetManager.uploadAsset(
      asset: data,
      fileName: fileName,
      tags: [fileName]
    ).sinkDisposed(receiveCompletion: nil) { [weak self] asset in
      guard let asset = asset else { return }
      self?.model?.updateStory({ story in
        story.landscapeImageAsset = asset
      })
      self?.updateStory(parameters: UpdateStoryParameters(landscapeImageAssetId: asset.assetId))
    }
  }
  
  func deleteStory() -> AnyPublisher<Void, Exception> {
    guard let storyId = fetchModel()?.fetchStory().storyId else { return .singleValue(()) }
    return self.storyManager.deleteStory(storyId: storyId).alsoOnValue { [weak self] in
      self?.eventManager.sendEvent(StoryDraftModelPresenterEvent.didDeleteStory(storyId: storyId))
    }
  }
  
  func reloadMessages() {
  }
  
  func insertMessage(text: String, previousMessageId: Int?, nextMessageId: Int?, selectedCharacterId: Int?) {
    guard let model = self.model else { return }
    /// Update Remote
    self.messageManager.insert(
      storyId: model.fetchStory().storyId,
      chapterId: model.currentChapter.chapterId,
      text: text,
      previousMessageId: previousMessageId,
      nextMessageId: nextMessageId,
      characterId: selectedCharacterId
    ).sinkDisposed { [weak self] result in
      switch result {
      case .failure(let error):
        self?.eventManager.sendEvent(StoryDraftModelPresenterEvent.didReceiveError(error))
      case .finished:
        break
      }
    } receiveValue: { [weak self] message in
      guard let message = message else { return }
      self?.model?.appendMessage(message: message)
      self?.eventManager.sendEvent(StoryDraftModelPresenterEvent.didInsertMessage(messageId: message.messageId))
    }
  }
  
  func removeMessage(messageId: Int) {
    /// Update Local
    self.model?.removeMessage(messageId: messageId)
    /// Update Remote
    self.messageManager.remove(messageId: messageId).sinkDisposed()
    /// Publish Changes
    self.eventManager.sendEvent(StoryDraftModelPresenterEvent.didRemoveMessage(messageId: messageId))
  }
  
  func updateMessage(messageId: Int, text: String?, displayIndex: Int?) {
    self.messageManager.update(
      messageId: messageId,
      text: text,
      displayIndex: displayIndex
    ).sinkDisposed()
  }
  
  func setCharacterForMessage(messageId: Int, characterId: Int?) {
    /// Update local
    self.model?.setCharacter(messageId: messageId, characterId: characterId)
    /// Update remote
    self.messageManager.setCharacter(messageId: messageId, characterId: characterId).sinkDisposed()
    /// Publish Event
    self.eventManager.sendEvent(StoryDraftModelPresenterEvent.didSetCharacter(messageId: messageId, characterId: characterId))
  }

  func reloadCharacters() {
    guard let model = model else { return }
    self.characterManager.listByStoryId(model.fetchStory().storyId)
      .sinkDisposed(receiveCompletion: nil) { [weak self] characters in
        self?.model?.setCharacters(characters)
        self?.eventManager.sendEvent(StoryDraftModelPresenterEvent.didRefreshCharacters)
      }
  }
  
  public func insertCharacter(_ character: Character) {
    self.model?.appendCharacter(character: character)
    self.eventManager.sendEvent(StoryDraftModelPresenterEvent.didInsertCharacter(characterId: character.characterId))
  }
  
  public func removeCharacter(_ characterId: Int) {
    /// Update Local
    self.model?.removeCharacter(characterId: characterId)
    /// Update Remote
    self.characterManager.remove(characterId: characterId).sinkDisposed()
    /// Publish Changes
    self.eventManager.sendEvent(StoryDraftModelPresenterEvent.didRemoveCharacter(characterId: characterId))
  }
  
  func updateCharacter(_ characterId: Int, name: String?, colorHexString: String?, messageAlignment: MessageAlignment?) {
    guard let model = self.model else { return }
    /// Update Local
    model.updateCharacter(
      characterId: characterId,
      name: name,
      colorHexString: colorHexString,
      messageAlignment: messageAlignment
    )
    
    /// Update Remote
    self.characterManager.update(
      characterId: characterId,
      name: name,
      colorHexString: colorHexString,
      messageAlignment: messageAlignment?.rawValue
    ).sinkDisposed()
    /// Publish Changes
    self.eventManager.sendEvent(StoryDraftModelPresenterEvent.didUpdateCharacter(characterId: characterId))
  }
  
  func setEditMode(_ editMode: StoryDraftEditMode) {
    self.editMode = editMode
    self.eventManager.sendEvent(StoryDraftModelPresenterEvent.didSetEditMode(editMode: editMode))
  }
}
