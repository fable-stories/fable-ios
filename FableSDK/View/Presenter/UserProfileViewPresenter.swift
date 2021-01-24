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
  
  public init(resolver: FBSDKResolver) {
    self.resolver = resolver
    self.networkManager = resolver.get()
    self.storyManager = resolver.get()
  }
  
  public func refreshData(userId: Int) -> AnyPublisher<UserProfile?, Exception> {
    self.networkManager.request(
      UserProfileResource(userId: userId)
    ).map { [weak self] wire in
      if let wire = wire, let model = UserProfile(wire: wire) {
        for story in model.stories {
          self?.storyManager.cacheStory(story: story)
        }
        return model
      }
      return nil
    }.eraseToAnyPublisher()
  }
}
