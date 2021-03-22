//
//  UserProfileViewPresenter.swift
//  FableSDKViewPresenters
//
//  Created by Andrew Aquino on 12/27/20.
//

import Foundation
import FableSDKResolver
import FableSDKModelManagers
import FableSDKModelObjects
import FableSDKWireObjects
import FableSDKResourceTargets
import Combine
import AppFoundation

public class UserProfileViewPresenter {
  
  private let resolver: FBSDKResolver
  private let networkManager: NetworkManagerV2
  private let storyManager: StoryManager
  private let userToUserManager: UserToUserManager
  
  private var userProfileByUserId: [Int: UserProfile] = [:]
  
  public init(resolver: FBSDKResolver) {
    self.resolver = resolver
    self.networkManager = resolver.get()
    self.storyManager = resolver.get()
    self.userToUserManager = resolver.get()
  }
  
  public func refreshData(userId: Int) -> AnyPublisher<UserProfile?, Exception> {
    if userId == -1 { return .singleValue(nil) }
    let publisher: AnyPublisher<UserProfile?, Exception> = self.networkManager.request(
      path: "/mobile/user/\(userId)/profile",
      method: .get,
      expect: WireUserProfile.self
    ).map { [weak self] wire in
      guard let self = self else { return nil }
      if let model = UserProfile(wire: wire) {
        self.userToUserManager.cacheUserToUser(
          userId: model.user.userId,
          userToUser: model.user.userToUser
        )
        for story in model.stories {
          self.storyManager.cacheStory(story: story)
        }
        self.userProfileByUserId[userId] = model
        return model
      }
      return nil
    }.eraseToAnyPublisher()
    return publisher
  }
}
