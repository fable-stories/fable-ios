//
//  FBSDKResolver.swift
//  FableSDKInterface
//
//  Created by MacBook Pro on 7/26/20.
//

import Foundation
import Firebolt
import FableSDKModelObjects
import FableSDKModelManagers
import FirebaseAnalytics


private let firebaseAnalyticsDelegate = FirebaseAnalyticsDelegate()

public class FBSDKResolver: Resolver {
  

  public init() {
    super.init("FBSDKResolver")

    // Core Managers
    
    register { GlobalContextManager() }
    register { EnvironmentManager(delegate: $0.get(expect: GlobalContextManager.self)) }
    register(expect: AnalyticsManager.self) { AnalyticsManagerImpl(networkManager: $0.get(), delegate: firebaseAnalyticsDelegate) }
    register { StateManager(environmentManager: $0.get()) }
    register(expect: UserManager.self) { UserManagerImpl(stateManager: $0.get(), networkManager: $0.get(), environmentManager: $0.get(), authManager: $0.get(), eventManager: $0.get()) }
    register(expect: AuthManager.self) {
      AuthManagerImpl(
        stateManager: $0.get(),
        environmentManager: $0.get(),
        networkManager: $0.get(),
        eventManager: $0.get(),
        analyticsManager: $0.get(),
        delegate: $0.get(expect: GlobalContextManager.self)
      )
    }
    
    register(expect: NetworkManager.self) { NetworkManagerImpl(environmentManager: $0.get()) }
    register(expect: NetworkManagerV2.self) { NetworkManagerV2Impl(environmentManager: $0.get()) }
    
    register {
      ConfigManager(
        networkManager: $0.get(),
        networkManagerV2: $0.get(),
        environmentManager: $0.get(),
        stateManager: $0.get()
      )
    }
    register { EventManager() }
    register { ResourceManager(networkManager: $0.get(), stateManager: $0.get(), authManager: $0.get()) }
    register(expect: StoryDraftManager.self) { StoryDraftManagerImpl(resourceManager: $0.get(), networkManager: $0.get(), authManager: $0.get()) }
    register(expect: DataStoreManager.self) {
      DataStoreManagerImpl(
        networkManager: $0.get(),
        storyManager: $0.get(),
        chapterManager: $0.get(),
        messageManager: $0.get(),
        characterManager: $0.get()
      )
    }
    register(expect: ImageManager.self) { ImageManagerImpl() }
    register(expect: StoryManager.self) { StoryManagerImpl(networkManager: $0.get(), userManager: $0.get()) }
    register(expect: ChapterManager.self) { ChapterManagerImpl(networkManager: $0.get()) }
    register(expect: MessageManager.self) { MessageManagerImpl(networkManager: $0.get(), authManager: $0.get()) }
    register(expect: CharacterManager.self) { CharacterManagerImpl(networkManager: $0.get(), authManager: $0.get()) }
    register(expect: FirebaseManager.self) { FirebaseManagerImpl(eventManager: $0.get(), authManager: $0.get()) }
    register(expect: CategoryManager.self) { CategoryManagerImpl(networkManager: $0.get()) }
    register(expect: AssetManager.self) { AssetManagerImpl(networkManager: $0.get(), authManager: $0.get()) }
    register(expect: StoryStatsManager.self) { StoryStatsManagerImpl(networkManager: $0.get()) }
  }
}

public class FirebaseAnalyticsDelegate: AnalyticsManagerDelegate {
  public func analyticsManager(firebaseTrackEvent event: String, parameters: [String : Any]?) {
    Analytics.logEvent(event, parameters: parameters)
  }
}
