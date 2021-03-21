//
//  UserProfile.swift
//  FableSDKModelObjects
//
//  Created by Andrew Aquino on 12/27/20.
//

import Foundation

public protocol UserToUser: Codable {
  var isFollowing: Bool { get }
  var isBlocked: Bool { get }
}

public struct MutableUserToUser: UserToUser {
  public var isFollowing: Bool
  public var isBlocked: Bool
  public init(isFollowing: Bool, isBlocked: Bool) {
    self.isFollowing = isFollowing
    self.isBlocked = isBlocked
  }
}

public protocol UserToStory: Codable {
  var isLiked: Bool { get }
  var isHidden: Bool { get }
  var isReported: Bool { get }
}

public struct MutableUserToStory: UserToStory {
  public var isLiked: Bool
  public var isHidden: Bool
  public var isReported: Bool
  public init(isLiked: Bool, isHidden: Bool, isReported: Bool) {
    self.isLiked = isLiked
    self.isHidden = isHidden
    self.isReported = isReported
  }
}

public struct UserProfile {
  public let user: User
  public let followCount: Int
  public let followerCount: Int
  public let stories: [Story]

  public init(user: User, followCount: Int, followerCount: Int, stories: [Story]) {
    self.user = user
    self.followCount = followCount
    self.followerCount = followerCount
    self.stories = stories
  }
}
