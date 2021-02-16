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
  
  private var userProfileByUserId: [Int: UserProfile] = [:]
  
  public init(resolver: FBSDKResolver) {
    self.resolver = resolver
    self.networkManager = resolver.get()
    self.storyManager = resolver.get()
  }
  
  public func refreshData(userId: Int) -> AnyPublisher<UserProfile?, Exception> {
    let publisher: AnyPublisher<UserProfile?, Exception> = self.networkManager.request(
      path: "/mobile/user/\(userId)/user-profile",
      method: .get,
      expect: WireUserProfile.self
    ).map { [weak self] wire in
      if let model = UserProfile(wire: wire) {
        for story in model.stories {
          self?.storyManager.cacheStory(story: story)
        }
        self?.userProfileByUserId[userId] = model
        return model
      }
      return nil
    }.eraseToAnyPublisher()
    if let userProfile = self.userProfileByUserId[userId] {
      publisher.sinkDisposed()
      return .singleValue(userProfile)
    }
    return publisher
  }
}
