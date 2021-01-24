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
