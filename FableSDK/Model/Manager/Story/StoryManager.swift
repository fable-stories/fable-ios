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
import FableSDKWireObjects

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
    return self.networkManager.request(
      path: "/story/\(storyId)",
      method: .get,
      expect: WireStory?.self
    ).map { [weak self] wire in
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
      path: "/story/\(storyId)",
      method: .put,
      parameters: UpdateStoryRequestBody(
        categoryId: parameters.categoryId,
        title: parameters.title,
        synopsis: parameters.synopsis,
        published: parameters.isPublished,
        portraitImageAssetId: parameters.portraitImageAssetId,
        landscapeImageAssetId: parameters.landscapeImageAssetId,
        squareImageAssetId: parameters.squareImageAssetId
      ),
      expect: EmptyResponseBody.self
    ).map { [weak self] _ in
      if let story = self?.storyById[storyId]?.value as? MutableStory {
        parameters.apply(story: story)
      }
      return ()
    }.eraseToAnyPublisher()
  }
  
  public func deleteStory(storyId: Int) -> AnyPublisher<Void, Exception> {
    self.networkManager.request(
      path: "/story/\(storyId)",
      method: .delete,
      expect: EmptyResponseBody.self
    ).mapVoid().eraseToAnyPublisher()
  }
  
  public func listByUserId(userId: Int) -> AnyPublisher<[Story], Exception> {
    self.networkManager.request(
      path: "/user/\(userId)/story",
      method: .delete,
      expect: WireCollection<WireStory>.self
    ).map { wire in
      wire.items.compactMap(MutableStory.init(wire:)) 
    }.eraseToAnyPublisher()
  }
}
