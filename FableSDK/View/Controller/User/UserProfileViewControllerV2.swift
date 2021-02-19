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
  private let userToUserManager: UserToUserManager
  
  private let presenter: UserProfileViewPresenter
  
  private var isMainProfileScreen: Bool
  private let initialUserId: Int
  private var isMyUser: Bool {
    initialUserId == Constants.myUserId
  }
  private var userId: Int {
    if let userId = authManager.authenticatedUserId, isMyUser {
      return userId
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
    self.userToUserManager = resolver.get()
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
    self.userToUserManager = resolver.get()
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
    let moreButton = UIBarButtonItem(
      image: UIImage(named: "more")?
        .resized(to: .sizeWithConstantDimensions(32.0))?
        .tinted(.black),
      style: .plain,
      target: self,
      action: #selector(didSelectMore(barButton:))
    )
    self.navigationItem.rightBarButtonItems = [
      moreButton,
      UIBarButtonItem(customView: activityView)
    ].compactMap { $0 }

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
          isFollowing: self.isMyUser ? nil : viewModel.user.userToUser.isFollowing,
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
  
  @objc private func didSelectMore(barButton: UIBarButtonItem) {
    if isMyUser {
      self.presentMoreForMyUser()
    } else {
      self.presentMoreForOtherUser()
    }
  }
  
  private func presentMoreForOtherUser() {
    guard let userToUser = userToUserManager.fetchUserToUser(userId: userId) else { return }
    let isBlocked = userToUser.isBlocked
    let alert = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
    alert.addAction(.init(title: isBlocked ? "Unblock" : "Block", style: .default, handler: { [weak self] _ in
      guard let self = self else { return }
      let newValue = !isBlocked
      self.userToUserManager.setUserBlocked(userId: self.userId, isBlocked: newValue).sinkDisposed()
    }))
    alert.addAction(.init(title: "Cancel", style: .default, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
  
  private func presentMoreForMyUser() {
    guard let navVC = self.navigationController else { return }
    self.eventManager.sendEvent(RouterRequestEvent.push(.userSettings, navigationController: navVC))
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
