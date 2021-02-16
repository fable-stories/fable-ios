//
//  UserToStoryManager.swift
//  FableSDKModelManagers
//
//  Created by Andrew Aquino on 2/15/21.
//

import Foundation
import Combine
import AppFoundation

public protocol UserToStoryManager {
  func reportStory(storyId: Int) -> AnyPublisher<Void, Exception>
  func setStoryHidden(storyId: Int, isHidden: Bool) -> AnyPublisher<Void, Exception>
}

public class UserToStoryManagerImpl: UserToStoryManager {
  
  private let networkManager: NetworkManagerV2
  
  public init(networkManager: NetworkManagerV2) {
    self.networkManager = networkManager
  }
  
  public func reportStory(storyId: Int) -> AnyPublisher<Void, Exception> {
    .singleValue(())
  }
  
  public func setStoryHidden(storyId: Int, isHidden: Bool) -> AnyPublisher<Void, Exception> {
    .singleValue(())
  }
}
