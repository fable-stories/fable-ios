//
//  CurrentStoryDraftManager.swift
//  FableSDKModelManagers
//
//  Created by Andrew Aquino on 11/28/20.
//

import Foundation


public protocol CurrentStoryDraftManager {
  func setStoryId(_ storyId: Int)
  func setCurrentChapterId(_ chapterId: Int)
}


public class CurrentStoryDraftManagerImpl: CurrentStoryDraftManager {
  
  private var currentStoryId: Int?
  private var currentChapterId: Int?
  
  public init() {
    
  }
  
  public func setStoryId(_ storyId: Int) {
  }
  
  public func setCurrentChapterId(_ chapterId: Int) {
  }
}
