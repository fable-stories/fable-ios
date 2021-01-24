//
//  StoryDetailViewController.swift
//  FableSDKViewControllers
//
//  Created by Andrew Aquino on 12/28/20.
//

import Foundation
import AsyncDisplayKit
import FableSDKResolver
import FableSDKModelManagers
import FableSDKViews
import FableSDKEnums

public final class StoryDetailViewController: ASDKViewController<StoryDetailNode> {
  
  private let resolver: FBSDKResolver
  private let storyManager: StoryManager
  private let userManager: UserManager
  private let eventManager: EventManager

  private let storyId: Int
  
  public init(resolver: FBSDKResolver, storyId: Int) {
    self.resolver = resolver
    self.storyManager = resolver.get()
    self.userManager = resolver.get()
    self.eventManager = resolver.get()
    self.storyId = storyId
    super.init(node: .init())
    self.node.delegate = self
  }
  
  public required init?(coder: NSCoder) {
    fatalError()
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Story Detail"
    
    self.eventManager.onEvent.sinkDisposed(receiveCompletion: nil) { (event) in
      switch event {
      case UserManagerEvent.didSetFollowStatus:
        self.refreshData()
      default:
        break
      }
    }
    
    self.refreshData()
  }
  
  public func refreshData() {
    self.storyManager.findById(storyId: storyId).sinkDisposed(receiveCompletion: nil) { [weak self] story in
      guard let self = self, let story = story else { return }
      let user = self.userManager.fetchUser(userId: story.userId)
      let viewModel = StoryDetailNode.ViewModel.init(
        storyId: story.storyId,
        miniUserDetail: .init(
          userId: story.userId,
          avatarAsset: user?.avatarAsset?.objectUrl,
          userName: user?.displayName ?? "User",
          isFollowing: self.userManager.currentUser?.userId == user?.userId ? nil :
            user?.userToUser?.isFollowing == true
        ),
        landscapeAsset: story.landscapeImageAsset?.objectUrl,
        title: story.title,
        synopsis: story.synopsis
      )
      self.node.setViewModel(viewModel)
    }
  }
}

extension StoryDetailViewController: StoryDetailNodeDelegate {
  public func storyDetailNode(didSelectStartStory storyId: Int) {
    self.eventManager.sendEvent(RouterRequestEvent.present(.story(storyId: storyId), viewController: self))
  }
  
  public func storyDetailNode(didSelectUser userId: Int) {
    guard let navVC = self.navigationController else { return }
    self.eventManager.sendEvent(RouterRequestEvent.push(.userProfile(userId: userId), navigationController: navVC))
  }
  
  public func storyDetailNode(didSelectFollowButton followButton: FBSDKFollowButton, userId: Int, isFollowing: Bool) {
    let isFollowing = !isFollowing
    followButton.isLoading = true
    /// Update remote
    self.userManager.setFollowStatus(userId: userId, isFollowing: isFollowing)
      .sinkDisposed(receiveCompletion: { [weak self, weak followButton] result in
        followButton?.isLoading = false
        /// Update local
        guard var viewModel = self?.node.viewModel else { return }
        viewModel.miniUserDetail.isFollowing = isFollowing
        self?.node.setViewModel(viewModel)
      }, receiveValue: nil)
  }
}
