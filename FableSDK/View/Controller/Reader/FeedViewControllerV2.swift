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

public class FeedViewControllerV2: ASDKViewController<FeedNode> {
  
  private let resolver: FBSDKResolver
  
  /// TODO: move feed call into it's own manager
  private let networkManager: NetworkManagerV2
  private let eventManager: EventManager

  public init(resolver: FBSDKResolver) {
    self.resolver = resolver
    self.networkManager = resolver.get()
    self.eventManager = resolver.get()
    super.init(node: .init())
    self.node.delegate = self
  }
  
  public required init?(coder: NSCoder) {
    fatalError()
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Fable Stories"
    
    self.refreshData()
  }
  
  private func refreshData() {
    networkManager.request(
      GetFeed()
    ).sinkDisposed(receiveCompletion: nil) { [weak self] wire in
      guard let self = self else { return }
      let categories = wire?.items.compactMap { Kategory(wire: $0) } ?? []
      self.node.sections = categories.compactMap { category in
        if category.stories.isEmpty { return nil }
        return FeedNode.Section.category(.init(category: category, stories: category.stories))
      }
    }
  }
}

extension FeedViewControllerV2: FeedNodeDelegate {
  public func feedNode(didSelectStory storyId: Int) {
    self.eventManager.sendEvent(RouterRequestEvent.present(.storyDetail(storyId: storyId), viewController: self))
  }
}
