//
//  UserProfile.swift
//  FableSDKModelObjects
//
//  Created by Andrew Aquino on 12/27/20.
//

import Foundation

public struct UserToUser: Codable {
  public let isFollowing: Bool
  public init(isFollowing: Bool) {
    self.isFollowing = isFollowing
  }
}

public protocol UserToStory: Codable {
  var liked: Bool { get }
  var isHidden: Bool { get }
  var isReported: Bool { get }
}

public struct MutableUserToStory: UserToStory {
  public var liked: Bool
  public var isHidden: Bool
  public var isReported: Bool
  public init(liked: Bool, isHidden: Bool, isReported: Bool) {
    self.liked = liked
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
