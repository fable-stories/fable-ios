//
//  ResourceManager.swift
//  FableSDKResourceManagers
//
//  Created by Andrew Aquino on 3/22/20.
//

import AppFoundation
import FableSDKEnums
import FableSDKModelObjects
import FableSDKResourceTargets
import FableSDKWireObjects
import Foundation
import NetworkFoundation
import ReactiveSwift


public final class ResourceManager {
  private let networkManager: NetworkManager
  private let stateManager: StateManager
  private let authManager: AuthManager

  public init(
    networkManager: NetworkManager,
    stateManager: StateManager,
    authManager: AuthManager
  ) {
    self.networkManager = networkManager
    self.stateManager = stateManager
    self.authManager = authManager
  }

  // MARK: Character

  public func appendNewCharacter(
    storyId: Int,
    userId: Int,
    name: String,
    colorHexString: String,
    messageAlignment: MessageAlignment
  ) -> SignalProducer<WireCharacter?, Never> {
    networkManager.request(
      CreateCharacter(),
      parameters: CreateCharacterRequestBody(
        storyId: storyId,
        userId: userId,
        name: name,
        colorHexString: colorHexString,
        messageAlignment: messageAlignment.rawValue
      )
    )
    .skipError()
  }

  public func removeCharacter(storyId: Int, characterId: Int) -> SignalProducer<EmptyResponseBody?, Never> {
    networkManager.request(
      RemoveCharacterById(characterId: characterId)
    )
    .skipError()
  }
  
  public func refreshCharacters(storyId: Int) -> SignalProducer<[WireCharacter], Never> {
    networkManager.request(
      GetCharactersByStoryId(storyId: storyId)
    )
    .map { $0?.items ?? [] }
    .skipError()
  }
  
  public func updateCharacter(
    characterId: Int,
    name: String?,
    colorHexString: String?,
    messageAlignment: MessageAlignment?
  ) -> SignalProducer<Void, Never> {
    networkManager.request(
      UpdateDraftCharacter(characterId: characterId),
      parameters: UpdateCharacterRequestBody(
        name: name,
        colorHexString: colorHexString,
        messageAlignment: messageAlignment?.rawValue
      )
    )
      .skipError()
      .mapVoid()
  }

  // MARK: Choices

  public func attachChoiceBlock(
    messageId: Int
  ) -> SignalProducer<WireRichCollection?, Never> {
    networkManager.request(
      AttachChoiceBlockToMessage(
        messageId: messageId
      )
    )
    .skipError()
  }

  // MARK: Collection

  public func upsertRichCollection(richCollection: WireRichCollection) -> SignalProducer<WireRichCollection?, Never> {
    networkManager.request(
      UpsertRichCollection(),
      parameters: richCollection
    )
    .skipError()
  }

  public func getRichCollection(storyId: Int) -> SignalProducer<WireRichCollection?, Never> {
    networkManager.request(
      GetCollectionByStoryId(storyId: storyId)
    )
    .skipError()
  }

  // MARK: Config

  public func getConfig() -> SignalProducer<WireConfig?, Never> {
    networkManager.request(
      GetConfig()
    )
    .skipError()
  }

  // MARK: Chapter

  public func refreshChapter(chapterId: Int) -> SignalProducer<WireChapter?, Never> {
    networkManager.request(
      GetDraftChapter(chapterId: chapterId)
    )
    .skipError()
  }

  public func refreshChapters(storyId: Int) -> SignalProducer<[WireChapter], Never> {
    networkManager.request(
      GetDraftChapters(storyId: storyId)
    )
    .map { $0?.items ?? [] }.skipError()
  }

  // MARK: MessageGroup

  public func refreshMessageGroups(storyId: Int) -> SignalProducer<[WireMessageGroup], Never> {
    networkManager.request(
      GetDraftMessageGroups(storyId: storyId)
    )
    .map { $0?.items ?? [] }.skipError()
  }

  public func refreshMessageGroups(storyId: Int, chapterId: Int) -> SignalProducer<[WireMessageGroup], Never> {
    networkManager.request(
      RefreshMessageGroups(chapterId: chapterId)
    )
    .map { $0?.items ?? [] }.skipError()
  }

  public func appendNewMessageGroup(storyId: Int, chapterId: Int) -> SignalProducer<WireMessageGroup?, Never> {
    networkManager.request(
      CreateDraftMessageGroup(storyId: storyId, chapterId: chapterId)
    )
    .skipError()
  }

  public func deleteMessageGroup(storyId: Int, chapterId: Int, messageGroupId: Int) -> SignalProducer<WireMessageGroup?, Never> {
    networkManager.request(
      DeleteDraftMessageGroup(storyId: storyId, chapterId: chapterId, messageGroupId: messageGroupId)
    )
    .skipError()
  }

  public func upsertMessageGroups(messageGroups: [MessageGroup]) -> SignalProducer<[WireMessageGroup], Never> {
    guard messageGroups.isNotEmpty else { return .empty }
    let wireMessageGroups = messageGroups.map { $0.toWire() }
    return networkManager.request(
      UpsertMessageGroup(),
      parameters: WireCollection<WireMessageGroup>(items: wireMessageGroups)
    )
    .map { $0?.items ?? [] }.skipError()
  }

  // MARK: Message

  public func appendNewMessage(
    userId: Int,
    storyId: Int,
    chapterId: Int,
    text: String,
    characterId: Int?,
    previousMessageId: Int?,
    nextMessageId: Int?,
    active: Bool
  ) -> SignalProducer<WireMessage?, Never> {
    networkManager.request(
      CreateMessage(),
      parameters: CreateMessageRequestBody(
        userId: userId,
        storyId: storyId,
        chapterId: chapterId,
        text: text,
        characterId: characterId,
        previousMessageId: previousMessageId,
        nextMessageId: nextMessageId,
        active: active
      )
    )
    .skipError()
  }

  public func removeMessage(
    messageId: Int
  ) -> SignalProducer<EmptyResponseBody?, Never> {
    networkManager.request(
      DeleteDraftMessage(messageId: messageId)
    )
    .skipError()
  }

  public func updateMessage(
    messageId: Int,
    text: String? = nil,
    displayIndex: Int? = nil,
    nextMessageId: Int? = nil,
    active: Bool? = nil
  ) -> SignalProducer<Void, Never> {
    networkManager.request(
      UpdateMessage(messageId: messageId),
      parameters: .init(
        text: text,
        displayIndex: displayIndex,
        nextMessageId: nextMessageId,
        active: active
      )
    )
    .skipError()
    .mapVoid()
  }

  public func upsertMessages(
    messages: [WireMessage]
  ) -> SignalProducer<WireCollection<WireMessage>?, Never> {
    guard messages.isNotEmpty else { return .empty }
    return networkManager.request(
      UpsertMessages(),
      parameters: WireCollection(items: messages)
    )
    .skipError()
  }

  public func refreshMessages(
    chapterId: Int
  ) -> SignalProducer<[WireMessage], Never> {
    networkManager.request(
      RefreshMessages(chapterId: chapterId)
    )
    .map { $0?.items ?? [] }
    .skipError()
  }

  public func refreshMessages(
    storyId: Int
  ) -> SignalProducer<[WireMessage], Never> {
    networkManager.request(
      RefreshMessagesByStoryId(storyId: storyId)
    )
    .map { $0?.items ?? [] }
    .skipError()
  }

  // MARK: Modifiers
  
  // TODO:

  public func attachModifiers(
    messageId: Int,
    modifierId: Int,
    modifierKind: ModifierKind
  ) -> SignalProducer<WireMessage?, Never> {
    .empty
  }

  public func detachModifiers(
    messageId: Int,
    modifierIds: [Int]
  ) -> SignalProducer<WireMessage?, Never> {
    .empty
  }

  // MARK: Story

  public func refreshStory(storyId: Int) -> SignalProducer<WireStory?, Never> {
    networkManager.request(
      GetStory(storyId: storyId)
    )
    .skipError()
  }

  public func refreshStories(userId: Int) -> SignalProducer<[WireStory], Never> {
    networkManager.request(
      GetStoriesByUser(userId: userId)
    )
    .map { $0?.items ?? [] }
    .skipError()
  }

  public func removeStory(storyId: Int) -> SignalProducer<WireStory?, NetworkError> {
    networkManager.request(
      RemoveStory(storyId: storyId)
    )
  }

  public func updateStory(
    storyId: Int,
    categoryId: Int? = nil,
    title: String? = nil,
    synopsis: String? = nil,
    published: Bool? = nil,
    landscapeImageAssetId: Int? = nil,
    squareImageAssetId: Int? = nil
  ) -> SignalProducer<Story?, Exception> {
    .empty
//    networkManager.request(
//      UpdateStory(storyId: storyId),
//      parameters: UpdateStoryRequestBody(
//        categoryId: categoryId,
//        title: title,
//        synopsis: synopsis,
//        published: published,
//        landscapeImageAssetId: landscapeImageAssetId,
//        squareImageAssetId: squareImageAssetId
//      )
//    )
//    .mapErrorException()
//    .map { $0.flatMap(Story.init) }
  }

  public func attachMediaToStory(storyId: Int, image: UIImage, imageKey: ImageKey) -> SignalProducer<WireStory?, Never> {
    networkManager.upload(
      AttachImageToStory(storyId: storyId, image: image, filename: imageKey.rawValue),
      parameters: AttachImageToStoryRequestBody(mediaKeyPath: imageKey.rawValue)
    )
    .skipError()
  }
  
  // MARK: Story Timeline
  
  public func createStoryTimeline(storyId: Int) -> SignalProducer<WireStoryTimeline?, Never> {
    guard let userId = authManager.authenticatedUserId else { return .empty }
    return networkManager.request(
      CreateStoryTimeline(userId: userId, storyId: storyId)
    )
      .skipError()
  }
  
  public func refreshStoryTimeline(storyId: Int) -> SignalProducer<WireStoryTimeline?, Never> {
    networkManager.request(
      GetStoryTimeline(storyId: storyId)
    )
    .skipError()
  }
  
  // MARK: Datastore
  
  public func fetchDataStore(storyId: Int) -> SignalProducer<DataStore?, Never> {
    SignalProducer.combineLatest(
      refreshStoryTimeline(storyId: storyId).flatMap(.latest) {
        [weak self] wire -> SignalProducer<WireStoryTimeline?, Never> in
        guard let self = self else { return .empty }
        if let wire = wire { return .init(value: wire) }
        return self.createStoryTimeline(storyId: storyId)
      },
      refreshStory(storyId: storyId),
      refreshChapters(storyId: storyId),
      refreshMessages(storyId: storyId),
      refreshCharacters(storyId: storyId)
    ).map { storyTimeline, story, chapters, messages, characters -> DataStore? in
      let chapters = chapters.compactMap(Chapter.init)
      guard
        let storyTimeline = storyTimeline.flatMap(StoryTimeline.init),
        let story = story.flatMap(MutableStory.init),
        chapters.isNotEmpty else { return nil }
      return DataStore(
        datastoreId: randomInt(),
        userId: story.userId,
        selectedChapterId: storyTimeline.currentChapterId,
        story: story,
        chapters: chapters.indexed(by: \.chapterId),
        messages: messages.compactMap(MutableMessage.init).indexed(by: \.messageId),
        characters: characters.compactMap(MutableCharacter.init).indexed(by: \.characterId)
      )
    }
  }

  // MARK: User

  public func refreshUserMe() -> SignalProducer<WireUser?, NetworkError> {
    guard let userId = stateManager.state().currentUser?.userId else { return .empty }
    return networkManager.request(
      GetUser(userId: userId)
    )
  }

  public func refreshUser(userId: Int) -> SignalProducer<WireUser?, NetworkError> {
    networkManager.request(
      GetUser(userId: userId)
    )
  }

  public func updateUser(
    userId: Int,
    userName: String? = nil,
    biography: String? = nil,
    avatarAssetId: Int? = nil
  ) -> SignalProducer<Void, Exception> {
    networkManager.request(
      UpdateUser(userId: userId),
      parameters: UpdateUserRequestBody(
        userName: userName,
        biography: biography,
        avatarAssetId: avatarAssetId
      )
    )
    .mapVoid()
    .mapErrorException()
  }

  public func attachUserProfileImage(
    userId: Int,
    image: UIImage
  ) -> SignalProducer<WireUser?, NetworkError> {
    return .empty
  }

  // MARK: Category

  public func refreshCategories() -> SignalProducer<[WireKategory], Never> {
    networkManager.request(
      RefreshCategories()
    )
    .map { $0?.items ?? [] }
    .skipError()
  }
  
  // MARK: Asset
  
  public func uploadAsset(userId: Int, asset: Data, fileName: String, tags: [String]) -> SignalProducer<Asset?, Exception> {
    networkManager.upload(
      UploadAssetRequest(
        userId: userId,
        file: asset,
        fileName: fileName,
        tags: tags
      )
    )
      .map { wire in wire.flatMap(Asset.init) }
      .mapErrorException()
  }
}
