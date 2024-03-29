//
//  FeedViewControllerV2.swift
//  FableSDKViewControllers
//
//  Created by Andrew Aquino on 1/4/21.
//

import Foundation
import AsyncDisplayKit
import FableSDKViews
import FableSDKResolver
import FableSDKModelManagers
import FableSDKResourceTargets
import FableSDKModelObjects
import FableSDKWireObjects
import FableSDKFoundation
import NetworkFoundation
import FableSDKEnums

public class FeedViewControllerV2: ASDKViewController<FeedNode> {
  
  private let resolver: FBSDKResolver
  
  /// TODO: move feed call into it's own manager
  private let networkManager: NetworkManagerV2
  private let eventManager: EventManager
  private let authManager: AuthManager
  private let userToStoryManager: UserToStoryManager
  private let analyticsManager: AnalyticsManager
  
  private let activityView = UIActivityIndicatorView(style: .medium)

  public init(resolver: FBSDKResolver) {
    self.resolver = resolver
    self.networkManager = resolver.get()
    self.eventManager = resolver.get()
    self.authManager = resolver.get()
    self.userToStoryManager = resolver.get()
    self.analyticsManager = resolver.get()
    super.init(node: .init())
    self.node.delegate = self
  }
  
  public required init?(coder: NSCoder) {
    fatalError()
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Fable Stories"
    self.navigationItem.rightBarButtonItems = [
      UIBarButtonItem(customView: activityView)
    ]
    
    self.eventManager.onEvent.sinkDisposed(receiveCompletion: nil) { [weak self] (event) in
      switch event {
      case UserToStoryManagerEvent.didReportStory, UserToStoryManagerEvent.didSetStoryHidden:
        self?.refreshData()
      default:
        break
      }
    }

    self.refreshData()
  }
  
  private func refreshData() {
    self.activityView.startAnimating()
    networkManager.request(
      path: "/mobile/feed",
      method: .get,
      expect: WireCollection<WireKategory>.self
    ).sinkDisposed(receiveCompletion: { [weak self] _ in
      self?.activityView.stopAnimating()
    }) { [weak self] wire in
      guard let self = self else { return }
      let categories = wire.items.compactMap { wireCategory -> Kategory? in
        let stories = wireCategory.stories?.compactMap { (wireStory: WireStory) -> Story? in
          guard let story = MutableStory.init(wire: wireStory) else { return nil }
          /// parse metadata
          if let myUserId = self.authManager.authenticatedUserId,
             let userToStory = wireStory.userToStory.flatMap(MutableUserToStory.init(wire:)) {
            self.userToStoryManager.cacheUserToStory(
              userId: myUserId,
              storyId: story.storyId,
              userToStory: userToStory
            )
          }
          return story
        }
        return Kategory(wire: wireCategory)?.copy(stories: stories)
      }
      self.node.sections = categories.compactMap { category in
        let stories = category.stories.filter { story in
          if let userId = self.authManager.authenticatedUserId {
            if let userToStory = self.userToStoryManager.fetchUserToStory(userId: userId, storyId: story.storyId) {
              /// don't show the story in the User's feed if the User hid it or reported it
              if userToStory.isHidden || userToStory.isReported { return false }
            }
          }
          return true
        }
        if stories.isEmpty { return nil }
        return FeedNode.Section.category(.init(category: category, stories: stories))
      }
    }
  }
}

extension FeedViewControllerV2: FeedNodeDelegate {
  public func feedNode(didSelectStory storyId: Int) {
    if authManager.isLoggedIn {
      self.analyticsManager.trackEvent(AnalyticsEvent.didSelectStoryInFeed, properties: ["story_id": storyId])
      self.eventManager.sendEvent(RouterRequestEvent.present(.storyDetail(storyId: storyId), viewController: self))
    } else {
      self.eventManager.sendEvent(RouterRequestEvent.present(.login, viewController: self))
    }
  }
  
  public func feedNode(didPullToRefresh node: FeedNode) {
    self.refreshData()
  }

  public func feedNode(didTapBackgroundImage node: FeedNode) {
  }
}
