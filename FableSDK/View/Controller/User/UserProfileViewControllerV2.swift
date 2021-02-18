//
//  UserProfileViewControllerV2.swift
//  FableSDKViewControllers
//
//  Created by Andrew Aquino on 12/26/20.
//

import Foundation
import AsyncDisplayKit
import AppFoundation
import FableSDKViews
import FableSDKResolver
import FableSDKModelManagers
import FableSDKViewPresenters
import FableSDKModelObjects
import FableSDKEnums
import Kingfisher

private struct Constants {
  public static let myUserId: Int = -1
}

public class UserProfileViewControllerV2: ASDKViewController<UserProfileNode> {

  private let resolver: FBSDKResolver
  private let userManager: UserManager
  private let eventManager: EventManager
  private let storyManager: StoryManager
  private let authManager: AuthManager
  
  private let presenter: UserProfileViewPresenter
  
  private var isMainProfileScreen: Bool
  private let initialUserId: Int
  private var isMyUser: Bool {
    initialUserId == Constants.myUserId
  }
  private var userId: Int? {
    if isMyUser {
      return authManager.authenticatedUserId
    }
    return initialUserId
  }
  
  private let activityView = UIActivityIndicatorView(style: .medium)

  public init(resolver: FBSDKResolver, userId: Int) {
    let authManager: AuthManager = resolver.get()
    self.resolver = resolver
    self.userManager = resolver.get()
    self.eventManager = resolver.get()
    self.storyManager = resolver.get()
    self.authManager = authManager
    self.presenter = UserProfileViewPresenter(resolver: resolver)
    self.isMainProfileScreen = false
    self.initialUserId = {
      if let authenticatedUserId = authManager.authenticatedUserId,
         authenticatedUserId == userId {
        return Constants.myUserId
      }
      return userId
    }()
    super.init(node: .init())
    self.node.delegate = self
    self.node.setIsMyUser(isMyUser)
  }
  
  public init(resolver: FBSDKResolver) {
    self.resolver = resolver
    self.userManager = resolver.get()
    self.eventManager = resolver.get()
    self.storyManager = resolver.get()
    self.authManager = resolver.get()
    self.presenter = UserProfileViewPresenter(resolver: resolver)
    self.isMainProfileScreen = true
    self.initialUserId = Constants.myUserId
    super.init(node: .init())
    self.node.delegate = self
    self.node.setIsMyUser(isMyUser)
  }
  
  public required init?(coder: NSCoder) {
    fatalError()
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "User Profile"
    self.neverShowPlaceholders = true
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityView)

    self.eventManager.onEvent.sinkDisposed(receiveCompletion: nil) { [weak self] event in
      switch event {
      case AuthManagerEvent.userDidSignIn, AuthManagerEvent.userDidSignOut,
           StoryDraftModelPresenterEvent.didDeleteStory,
           UserManagerEvent.didSetFollowStatus,
           WriterDashboardEvent.didStartNewStory:
        self?.refreshData()
      default:
        break
      }
    }

    self.refreshData()
  }

  public func refreshData() {
    guard let userId = userId else {
      self.node.sections.removeAll()
      return
    }
    
    self.activityView.startAnimating()
    
    self.presenter.refreshData(userId: userId).sinkDisposed(receiveCompletion: { [weak self] completion in
      self?.activityView.stopAnimating()
    }) { [weak self] (viewModel) in
      guard let self = self, let viewModel = viewModel else { return }
      let user = viewModel.user
      let stories = viewModel.stories
      var sections: [UserProfileNode.Section] = []
      sections.append(.header(
        .init(
          userId: user.userId,
          avatarURL: user.avatarAsset?.objectUrl,
          userName: user.userName,
          biography: user.biography,
          followCount: viewModel.followCount,
          followerCount: viewModel.followerCount,
          storyCount: stories.count,
          isFollowing: self.isMyUser ? nil : (viewModel.user.userToUser?.isFollowing ?? false),
          isMyUser: self.isMyUser
        )
      ))
      if self.isMyUser {
        let draftStories = stories
          .filter { !$0.isPublished }
          .map { story -> UserProfileNode.Section.StoryViewModel in
            return .init(
              storyId: story.storyId,
              title: story.title,
              portraitAsset: {
                if let key = story.portraitImageAsset?.objectUrl.absoluteStringByTrimmingQuery {
                  if let image = ImageCache.default.retrieveImageInMemoryCache(forKey: key) {
                    return image
                  }
                }
                return story.portraitImageAsset?.objectUrl
              }()
            )
          }
        if draftStories.isNotEmpty {
          sections.append(.draftStories(draftStories))
        }
      }
      let publishedStories = stories
        .filter { $0.isPublished }
        .map { story -> UserProfileNode.Section.StoryViewModel in
          .init(storyId: story.storyId, title: story.title, portraitAsset: story.portraitImageAsset?.objectUrl)
        }
      if publishedStories.isNotEmpty {
        sections.append(.publishedStories(publishedStories))
      }
      self.node.sections = sections
    }
  }
  
  private func presentStoryEditor(storyId: Int) {
    self.eventManager.sendEvent(RouterRequestEvent.present(.storyEditor(storyId: storyId), viewController: self))
  }
  
  private func presentStoryReader(storyId: Int) {
    self.eventManager.sendEvent(RouterRequestEvent.present(.storyDetail(storyId: storyId), viewController: self))
  }
}

extension UserProfileViewControllerV2: UserProfileNodeDelegate {
  public func userProfileNode(didSelectStory storyId: Int) {
    if self.isMyUser {
      self.presentStoryEditor(storyId: storyId)
    } else {
      self.presentStoryReader(storyId: storyId)
    }
  }
  
  public func userProfileNode(didSelectFollowersCount node: UserProfileNode) {
    guard let userId = self.userId else { return }
    self.userManager.refreshUsers(followingUserId: userId)
      .sinkDisposed(receiveCompletion: nil) { [weak self] users in
        guard let self = self, users.isNotEmpty else { return }
        let userIds = users.map { $0.userId }
        if self.isMyUser, self.isMainProfileScreen {
          self.eventManager.sendEvent(RouterRequestEvent.present(.userList(userIds: userIds, title: "Followers"), viewController: self))
        } else if let navigationController = self.navigationController {
          self.eventManager.sendEvent(RouterRequestEvent.push(.userList(userIds: userIds, title: "Followers"), navigationController: navigationController))
        }
      }
  }
  
  public func userProfileNode(didSelectFollowingCount node: UserProfileNode) {
    guard let userId = self.userId else { return }
    self.userManager.refreshUsers(followedByuserId: userId)
      .sinkDisposed(receiveCompletion: nil) { [weak self] (users) in
        guard let self = self, users.isNotEmpty else { return }
        let userIds = users.map { $0.userId }
        if self.isMyUser, self.isMainProfileScreen {
          self.eventManager.sendEvent(RouterRequestEvent.present(.userList(userIds: userIds, title: "Following"), viewController: self))
        } else if let navigationController = self.navigationController {
          self.eventManager.sendEvent(RouterRequestEvent.push(.userList(userIds: userIds, title: "Following"), navigationController: navigationController))
        }
      }
  }
  
  public func userProfileNode(
    didTapFollowButton followButton: FBSDKFollowButton,
    node: UserProfileNode,
    userId: Int,
    isFollowing: Bool
  ) {
    followButton.isLoading = true
    /// Update remote
    self.userManager.setFollowStatus(userId: userId, isFollowing: isFollowing)
      .sinkDisposed(receiveCompletion: { [weak followButton] result in
        followButton?.isLoading = false
        followButton?.isFollowing = isFollowing
      }, receiveValue: nil)
  }
  
  public func userProfileNode(didTapBackgroundImage node: UserProfileNode) {
    self.eventManager.sendEvent(RouterRequestEvent.present(.login, viewController: self))
  }
}
