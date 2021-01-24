//
//  WireUserProfile.swift
//  FableSDKWireObjects
//
//  Created by Andrew Aquino on 12/27/20.
//

import Foundation
import FableSDKModelObjects

public struct WireUserToUser: Codable {
  public let isFollowing: Bool
}

public extension UserToUser {
  init?(wire: WireUserToUser) {
    self.init(isFollowing: wire.isFollowing)
  }
}

public struct WireUserProfile: Codable {
  public let user: WireUser
  public let followCount: Int
  public let followerCount: Int
  public let stories: [WireStory]
}

public extension UserProfile {
  init?(wire: WireUserProfile) {
    guard let user = User(wire: wire.user) else { return nil }
    self.init(
      user: user,
      followCount: wire.followCount,
      followerCount: wire.followerCount,
      stories: wire.stories.compactMap(MutableStory.init(wire:))
    )
  }
}
