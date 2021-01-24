//
//  StoryManager.swift
//  FableSDKModelManagers
//
//  Created by Andrew Aquino on 11/28/20.
//

import Foundation
import AppFoundation
import NetworkFoundation
import Combine
import FableSDKModelObjects
import FableSDKResourceTargets

public protocol StoryManager {
  func findById(storyId: Int) -> AnyPublisher<Story?, Exception>
  func fetchById(storyId: Int) -> Story?
  func updatebyId(storyId: Int, parameters: UpdateStoryParameters) -> AnyPublisher<Void, Exception>
  func deleteStory(storyId: Int) -> AnyPublisher<Void, Exception>
  func listByUserId(userId: Int) -> AnyPublisher<[Story], Exception>
  func cacheStory(story: Story)
}

public class StoryManagerImpl: StoryManager {
  
  private let networkManager: NetworkManagerV2
  private let userManager: UserManager
  private var storyById: [Int: CachedItem<Story>] = [:]
  
  public init(
    networkManager: NetworkManagerV2,
    userManager: UserManager
  ) {
    self.networkManager = networkManager
    self.userManager = userManager
  }
  
  public func findById(storyId: Int) -> AnyPublisher<Story?, Exception> {
    /// return recently cached responses
    if let cache = self.storyById[storyId], abs(cache.cachedAt.timeIntervalSinceNow) <= 30 {
      return .singleValue(cache.value)
    }
    return self.networkManager.request(GetStory(storyId: storyId)).map { [weak self] wire in
      if let wire = wire, let story = MutableStory(wire: wire) {
        self?.storyById[story.storyId] = CachedItem(story)
        if let user = wire.user.flatMap(User.init(wire:)) {
          self?.userManager.cacheUser(user: user)
        }
        return story
      }
      return nil
    }.eraseToAnyPublisher()
  }
  
  public func fetchById(storyId: Int) -> Story? {
    storyById[storyId]?.value
  }

  public func cacheStory(story: Story) {
    storyById[story.storyId] = CachedItem(story)
  }
  
  public func updatebyId(storyId: Int, parameters: UpdateStoryParameters) -> AnyPublisher<Void, Exception> {
    self.networkManager.request(
      UpdateStory(storyId: storyId),
      parameters: UpdateStoryRequestBody(
        categoryId: parameters.categoryId,
        title: parameters.title,
        synopsis: parameters.synopsis,
        published: parameters.isPublished,
        portraitImageAssetId: parameters.portraitImageAssetId,
        landscapeImageAssetId: parameters.landscapeImageAssetId,
        squareImageAssetId: parameters.squareImageAssetId
      )
    ).map { [weak self] _ in
      if let story = self?.storyById[storyId]?.value as? MutableStory {
        parameters.apply(story: story)
      }
      return ()
    }.eraseToAnyPublisher()
  }
  
  public func deleteStory(storyId: Int) -> AnyPublisher<Void, Exception> {
    self.networkManager.request(
      DeleteStoryDraft(storyId: storyId)
    ).mapException().mapVoid().eraseToAnyPublisher()
  }
  
  public func listByUserId(userId: Int) -> AnyPublisher<[Story], Exception> {
    self.networkManager.request(
      GetStoriesByUser(userId: userId)
    ).mapException().map { wire in
      return wire?.items.compactMap(MutableStory.init(wire:)) ?? []
    }.eraseToAnyPublisher()
  }
}
