//
//  FBSDKResolver.swift
//  FableSDKInterface
//
//  Created by MacBook Pro on 7/26/20.
//

import Foundation
import Firebolt
import FableSDKEnums
import FableSDKModelObjects
import FableSDKModelManagers
import FirebaseAnalytics

private let firebaseAnalyticsDelegate = FirebaseAnalyticsDelegate()

public class FBSDKResolver: Resolver {
  

  public init() {
    super.init("FBSDKResolver")

    register { GlobalContextManager() }
    register { (resolver: FBSDKResolver) in
      EnvironmentManager(delegate: resolver.get(expect: GlobalContextManager.self))
    }
    register(expect: AnalyticsManager.self) { (resolver: FBSDKResolver) in
      AnalyticsManagerImpl(networkManager: resolver.get(), delegate: firebaseAnalyticsDelegate)
    }
    register { (resolver: FBSDKResolver) in
      StateManager(environmentManager: resolver.get())
    }
    register(expect: UserManager.self) { (resolver: FBSDKResolver) in
      UserManagerImpl(
        stateManager: resolver.get(),
        networkManager: resolver.get(),
        environmentManager: resolver.get(),
        authManager: resolver.get(),
        eventManager: resolver.get(),
        userToUserManager: resolver.get()
      )
    }
    register(expect: AuthManager.self) { (resolver: FBSDKResolver) in
      AuthManagerImpl(
        stateManager: resolver.get(),
        environmentManager: resolver.get(),
        networkManager: resolver.get(),
        networkManagerV2: resolver.get(),
        eventManager: resolver.get(),
        analyticsManager: resolver.get(),
        delegate: resolver.get(expect: GlobalContextManager.self)
      )
    }
    register(expect: NetworkManager.self) { (resolver: FBSDKResolver) in
      NetworkManagerImpl(environmentManager: resolver.get())
    }
    register(expect: NetworkManagerV2.self) { (resolver: FBSDKResolver) in
      NetworkManagerV2Impl(environmentManager: resolver.get())
    }
    register(expect: ConfigManager.self) { (resolver: FBSDKResolver) in
      ConfigManagerImpl(
        networkManager: resolver.get(),
        networkManagerV2: resolver.get(),
        environmentManager: resolver.get(),
        stateManager: resolver.get(),
        eventManager: resolver.get()
      )
    }
    register { EventManager() }
    register { (resolver: FBSDKResolver) in
      ResourceManager(networkManager: resolver.get(), stateManager: resolver.get(), authManager: resolver.get())
    }
    register(expect: StoryDraftManager.self) { (resolver: FBSDKResolver) in
      StoryDraftManagerImpl(resourceManager: resolver.get(), networkManager: resolver.get(), authManager: resolver.get())
    }
    register(expect: DataStoreManager.self) { (resolver: FBSDKResolver) in
      DataStoreManagerImpl(
        networkManager: resolver.get(),
        storyManager: resolver.get(),
        chapterManager: resolver.get(),
        messageManager: resolver.get(),
        characterManager: resolver.get()
      )
    }
    register(expect: ImageManager.self) { (resolver: FBSDKResolver) in
      ImageManagerImpl()
    }
    register(expect: StoryManager.self) { (resolver: FBSDKResolver) in
      StoryManagerImpl(
        networkManager: resolver.get(),
        userManager: resolver.get(),
        userToStoryManager: resolver.get(),
        authManager: resolver.get()
      )
    }
    register(expect: ChapterManager.self) { (resolver: FBSDKResolver) in
      ChapterManagerImpl(networkManager: resolver.get())
    }
    register(expect: MessageManager.self) { (resolver: FBSDKResolver) in
      MessageManagerImpl(networkManager: resolver.get(), authManager: resolver.get())
    }
    register(expect: CharacterManager.self) { (resolver: FBSDKResolver) in
      CharacterManagerImpl(networkManager: resolver.get(), authManager: resolver.get())
    }
    register(expect: FirebaseManager.self) { (resolver: FBSDKResolver) in
      FirebaseManagerImpl(eventManager: resolver.get(), authManager: resolver.get())
    }
    register(expect: CategoryManager.self) { (resolver: FBSDKResolver) in
      CategoryManagerImpl(networkManager: resolver.get())
    }
    register(expect: AssetManager.self) { (resolver: FBSDKResolver) in
      AssetManagerImpl(networkManager: resolver.get(), authManager: resolver.get())
    }
    register(expect: StoryStatsManager.self) { (resolver: FBSDKResolver) in
      StoryStatsManagerImpl(networkManager: resolver.get())
    }
    register(expect: UserToStoryManager.self) { (resolver: FBSDKResolver) in
      UserToStoryManagerImpl(
        networkManager: resolver.get(),
        eventManager: resolver.get(),
        authManager: resolver.get()
      )
    }
    register(expect: UserToUserManager.self) { (resolver: FBSDKResolver) in
      UserToUserManagerImpl(
        networkManager: resolver.get(),
        eventManager: resolver.get(),
        authManager: resolver.get()
      )
    }
  }
}

public class FirebaseAnalyticsDelegate: AnalyticsManagerDelegate {
  public func analyticsManager(firebaseTrackEvent event: String, parameters: [String : Any]?) {
    switch event {
    case AnalyticsEvent.didLogin.rawValue:
      Analytics.logEvent(AnalyticsEventLogin, parameters: parameters)
    case AnalyticsEvent.didSignUp.rawValue:
      Analytics.logEvent(AnalyticsEventSignUp, parameters: parameters)
    default:
      Analytics.logEvent(event, parameters: parameters)
    }
  }
}
