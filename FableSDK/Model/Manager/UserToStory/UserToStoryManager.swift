//
//  UserToStoryManager.swift
//  FableSDKModelManagers
//
//  Created by Andrew Aquino on 2/15/21.
//

import Foundation
import Combine
import AppFoundation
import NetworkFoundation
import FableSDKModelObjects
import FableSDKFoundation

public enum UserToStoryManagerEvent: EventContext {
  case didReportStory(storyId: Int)
  case didSetStoryHidden(storyId: Int, isHidden: Bool)
}

public protocol UserToStoryManager {
  func setStoryReported(storyId: Int, isReported: Bool) -> AnyPublisher<Void, Exception>
  func setStoryHidden(storyId: Int, isHidden: Bool) -> AnyPublisher<Void, Exception>
  func cacheUserToStory(userId: Int, storyId: Int, userToStory: UserToStory)
  func fetchUserToStory(userId: Int, storyId: Int) -> UserToStory?
  func updateByKey(userId: Int, storyId: Int, closure: @escaping (inout MutableUserToStory) -> Void)
}

public class UserToStoryManagerImpl: UserToStoryManager {
  
  private let networkManager: NetworkManagerV2
  private let eventManager: EventManager
  private let authManager: AuthManager
  
  private var userIdStoryIdToUserToStory: [String: UserToStory] = [:]

  public init(
    networkManager: NetworkManagerV2,
    eventManager: EventManager,
    authManager: AuthManager
  ) {
    self.networkManager = networkManager
    self.eventManager = eventManager
    self.authManager = authManager
  }
  
  public func cacheUserToStory(userId: Int, storyId: Int, userToStory: UserToStory) {
    self.userIdStoryIdToUserToStory["\(userId):\(storyId)"] = userToStory
  }
  
  public func fetchUserToStory(userId: Int, storyId: Int) -> UserToStory? {
    self.userIdStoryIdToUserToStory["\(userId):\(storyId)"]
  }
  
  public func updateByKey(userId: Int, storyId: Int, closure: @escaping (inout MutableUserToStory) -> Void) {
    if var userToStory = fetchUserToStory(userId: userId, storyId: storyId) as? MutableUserToStory {
      closure(&userToStory)
      cacheUserToStory(userId: userId, storyId: storyId, userToStory: userToStory)
    }
  }

  public func setStoryReported(storyId: Int, isReported: Bool) -> AnyPublisher<Void, Exception> {
    guard let myUserId = authManager.authenticatedUserId else { return .singleValue(()) }
    return self.networkManager.request(
      path: "/user/to/story/\(storyId)",
      method: .post,
      parameters: [
        "report": isReported
      ],
      expect: EmptyResponseBody.self
    )
    .mapVoid()
    .alsoOnValue { [weak self] in
      self?.updateByKey(userId: myUserId, storyId: storyId, closure: { userToStory in
        userToStory.isReported = true
      })
      self?.eventManager.sendEvent(UserToStoryManagerEvent.didReportStory(storyId: storyId))
    }
  }
  
  public func setStoryHidden(storyId: Int, isHidden: Bool) -> AnyPublisher<Void, Exception> {
    guard let myUserId = authManager.authenticatedUserId else { return .singleValue(()) }
    return self.networkManager.request(
      path: "/user/to/story/\(storyId)",
      method: .post,
      parameters: [
        "hide": isHidden
      ],
      expect: EmptyResponseBody.self
    )
    .mapVoid()
    .alsoOnValue { [weak self] in
      self?.updateByKey(userId: myUserId, storyId: storyId, closure: { userToStory in
        userToStory.isHidden = isHidden
      })
      self?.eventManager.sendEvent(UserToStoryManagerEvent.didSetStoryHidden(storyId: storyId, isHidden: isHidden))
    }
  }
}
