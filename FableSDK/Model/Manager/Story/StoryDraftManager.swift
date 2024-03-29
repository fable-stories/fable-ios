//
//  StoryDraftManager.swift
//  FableSDKModelManagers
//
//  Created by MacBook Pro on 8/10/20.
//

import Foundation
import AppFoundation
import ReactiveFoundation
import FableSDKResourceTargets
import FableSDKModelObjects
import ReactiveSwift
import Combine
import FableSDKWireObjects

public protocol StoryDraftManager {
  func fetchByStoryId(storyId: Int) -> StoryDraft?
  func refreshStoryDraft(storyId: Int) -> AnyPublisher<StoryDraft, Exception>
  func createStoryDraft() -> AnyPublisher<StoryDraft?, Exception>
  func fetchLatestOrCreateStoryDraft() -> AnyPublisher<StoryDraft, Exception>
}


public class StoryDraftManagerImpl: StoryDraftManager {
  private var storyDraftByStoryId: [Int: StoryDraft] = [:]
  
  private let resourceManager: ResourceManager
  private let networkManager: NetworkManagerV2
  private let authManager: AuthManager

  public init(
    resourceManager: ResourceManager,
    networkManager: NetworkManagerV2,
    authManager: AuthManager
  ) {
    self.resourceManager = resourceManager
    self.networkManager = networkManager
    self.authManager = authManager
  }
  
  public func fetchByStoryId(storyId: Int) -> StoryDraft? {
    storyDraftByStoryId[storyId]
  }
  
  public func refreshStoryDraft(
    storyId: Int
  ) -> AnyPublisher<StoryDraft, Exception> {
    let publisher: AnyPublisher<StoryDraft, Exception> = networkManager.request(
      path: "/story/\(storyId)/draft",
      method: .get
    ).map { [weak self] (wire: WireStoryDraft) in
      let storyDraft = StoryDraft(wire: wire)
      self?.storyDraftByStoryId[storyId] = storyDraft
      return storyDraft
    }
    .eraseToAnyPublisher()
    return publisher
  }
  
  public func createStoryDraft() -> AnyPublisher<StoryDraft?, Exception> {
    guard let userId = authManager.authenticatedUserId else { return .singleValue(nil) }
    return networkManager.request(
      path: "/user/\(userId)/draft/story",
      method: .post
    ).map { [weak self] (wire: WireStoryDraft) in
      let storyDraft = StoryDraft(wire: wire)
      self?.storyDraftByStoryId[storyDraft.storyId] = storyDraft
      return storyDraft
    }
    .eraseToAnyPublisher()
  }
  
  public func fetchLatestOrCreateStoryDraft() -> AnyPublisher<StoryDraft, Exception> {
    return networkManager.request(
      path: "/story/draft/latest",
      method: .get
    ).map { [weak self] (wire: WireStoryDraft) in
      let storyDraft = StoryDraft(wire: wire)
      self?.storyDraftByStoryId[storyDraft.storyId] = storyDraft
      return storyDraft
    }
    .eraseToAnyPublisher()
  }
}
