//
//  UserListViewController.swift
//  FableSDKViewControllers
//
//  Created by Andrew Aquino on 12/27/20.
//

import Foundation
import AsyncDisplayKit
import FableSDKResolver
import FableSDKViews
import FableSDKModelManagers
import FableSDKModelObjects

public class UserListViewController: ASDKViewController<UserListNode> {
  
  private let resolver: FBSDKResolver
  private let userManager: UserManager
  private let eventManager: EventManager

  private let userIds: Set<Int>
  private let users: [User]
  
  public init(resolver: FBSDKResolver, userIds: Set<Int>) {
    self.resolver = resolver
    self.userManager = resolver.get()
    self.eventManager = resolver.get()
    self.userIds = userIds
    self.users = []
    super.init(node: .init())
    self.node.delegate = self
  }
  
  public init(resolver: FBSDKResolver, users: [User]) {
    self.resolver = resolver
    self.userManager = resolver.get()
    self.eventManager = resolver.get()
    self.userIds = users.map { $0.userId }.toSet()
    self.users = users
    super.init(node: .init())
    self.node.delegate = self
  }
  
  public required init?(coder: NSCoder) {
    fatalError()
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    if users.isEmpty {
      self.userManager.refreshUsers(userIds: userIds).sinkDisposed(receiveCompletion: nil) { [weak self] users in
        self?.updateNode(users: users)
      }
    } else {
      self.updateNode(users: users)
    }
  }
  
  private func updateNode(users: [User]) {
    self.node.users = users.map { user in
      return UserListNode.UserViewModel(
        userId: user.userId,
        avatarAsset: user.avatarAsset?.objectUrl,
        userName: user.displayName,
        biography: user.biography ?? "",
        isFollowing: user.userToUser.isFollowing
      )
    }
  }
}

extension UserListViewController: UserListNodeDelegate {
  public func userListNode(didSelectUser userId: Int) {
    guard let navVC = self.navigationController else { return }
    self.eventManager.sendEvent(RouterRequestEvent.push(.userProfile(userId: userId), navigationController: navVC))
  }
}

