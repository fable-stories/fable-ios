//
//  DataStoreManager.swift
//  FableSDKInterface
//
//  Created by MacBook Pro on 8/10/20.
//

import Foundation
import AppFoundation
import ReactiveFoundation
import FableSDKModelObjects
import ReactiveSwift
import Combine

public struct CachedItem<T> {
  public let value: T
  public let cachedAt: Date
  public init(_ value: T) {
    self.value = value
    self.cachedAt = .now
  }
}

public protocol DataStoreManager {
  func refreshDataStore(storyDraft: StoryDraft) -> SignalProducer<DataStore?, Exception>
  func refreshDataStore(storyId: Int) -> AnyPublisher<DataStore?, Exception>
  func fetchDataStore(storyId: Int) -> DataStore?
}


public class DataStoreManagerImpl: DataStoreManager {
  private let queue = DispatchQueue.global(qos: .default)
  private var dataStoreByStoryId: [Int: CachedItem<DataStore>] = [:]
  
  private let networkManager: NetworkManagerV2
  private let storyManager: StoryManager
  private let chapterManager: ChapterManager
  private let messageManager: MessageManager
  private let characterManager: CharacterManager

  public init(
    networkManager: NetworkManagerV2,
    storyManager: StoryManager,
    chapterManager: ChapterManager,
    messageManager: MessageManager,
    characterManager: CharacterManager
  ) {
    self.networkManager = networkManager
    self.storyManager = storyManager
    self.chapterManager = chapterManager
    self.messageManager = messageManager
    self.characterManager = characterManager
  }

  public func refreshDataStore(storyDraft: StoryDraft) -> SignalProducer<DataStore?, Exception> {
    SignalProducer<DataStore?, Exception>.init(value: nil)
  }

  public func refreshDataStore(storyId: Int) -> AnyPublisher<DataStore?, Exception> {
    let storyData = Publishers.CombineLatest4(
      storyManager.findById(storyId: storyId),
      chapterManager.listByStoryId(storyId: storyId),
      messageManager.listByStoryId(storyId: storyId),
      characterManager.listByStoryId(storyId)
    )
    return storyData.map { [weak self] result in
      let (_story, chapters, messages, characters) = result
      guard let story = _story, let chapter = chapters.first else { return .none }
      let datastore = DataStore(
        userId: story.userId,
        selectedChapterId: chapter.chapterId,
        story: story,
        categories: nil,
        chapters: chapters.indexed(by: \.chapterId),
        messageGroups: nil,
        messages: messages.indexed(by: \.messageId),
        modifiers: nil,
        characters: characters.indexed(by: \.characterId),
        choices: nil,
        choiceGroups: nil,
        colorHexStrings: nil
      )
      self?.queue.sync { self?.dataStoreByStoryId[storyId] = CachedItem(datastore) }
      return datastore
    }.eraseToAnyPublisher()
  }
  
  public func fetchDataStore(storyId: Int) -> DataStore? {
    queue.sync {
      if let cache = dataStoreByStoryId[storyId], abs(cache.cachedAt.timeIntervalSinceNow) <= 30.0 {
        return cache.value
      }
      return nil
    }
  }
}
