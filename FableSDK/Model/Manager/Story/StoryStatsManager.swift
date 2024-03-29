//
//  StoryStatsManager.swift
//  FableSDKModelManagers
//
//  Created by Andrew Aquino on 1/4/21.
//

import Foundation
import Combine
import AppFoundation
import FableSDKResourceTargets

public protocol StoryStatsManager {
  func incrementViews(storyId: Int) -> AnyPublisher<Int, Exception>
}


public final class StoryStatsManagerImpl: StoryStatsManager {
  
  private let networkManager: NetworkManagerV2
  
  public init(networkManager: NetworkManagerV2) {
    self.networkManager = networkManager
  }
  
  public func incrementViews(storyId: Int) -> AnyPublisher<Int, Exception> {
    networkManager.request(
      path: "/story/\(storyId)/stats/views",
      method: .post
    )
    .map { (wire: IncrementStoryViewsResource.Response) in
      wire.views
    }
    .eraseToAnyPublisher()
  }
}
