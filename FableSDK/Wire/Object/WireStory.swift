//
//  WireStory.swift
//  FableSDKWireObjects
//
//  Created by MacBook Pro on 8/8/20.
//

import Foundation
import FableSDKModelObjects

public struct WireStory: Codable {
  public let storyId: Int?
  public let userId: Int?
  public let selectedChapterId: Int?
  public let categoryId: Int?
  public let squareImageAsset: WireAsset?
  public let portraitImageAsset: WireAsset?
  public let landscapeImageAsset: WireAsset?
  public let title: String?
  public let synopsis: String?
  public let chapterIds: Set<Int>?
  public let published: Bool?

  /// transinets
  public let user: WireUser?
  public let userToStory: WireUserToStory?
  public let storyStats: WireStoryStats?

  public init(
    storyId: Int? = nil,
    userId: Int? = nil,
    selectedChapterId: Int? = nil,
    categoryId: Int? = nil,
    squareImageUrl: URL? = nil,
    landscapeImageUrl: URL? = nil,
    title: String? = nil,
    synopsis: String? = nil,
    chapterIds: Set<Int>? = nil,
    isPublished: Bool? = nil,
    user: WireUser? = nil,
    userToStory: WireUserToStory? = nil,
    storyStats: WireStoryStats? = nil
  ) {
    self.storyId = storyId
    self.userId = userId
    self.selectedChapterId = selectedChapterId
    self.categoryId = categoryId
    self.landscapeImageAsset = nil
    self.squareImageAsset = nil
    self.portraitImageAsset = nil
    self.title = title
    self.synopsis = synopsis
    self.chapterIds = chapterIds
    self.published = isPublished
    self.user = user
    self.userToStory = userToStory
    self.storyStats = storyStats
  }
}

extension WireStory: CustomStringConvertible {
  public var description: String { prettyJSONString }
}

extension Story {
  public init?(wire: WireStory) {
    guard let storyId = wire.storyId else { return nil }
    guard let userId = wire.userId else { return nil }
    guard let isPublished = wire.published else { return nil }
    self.init(
      storyId: storyId,
      userId: userId,
      categoryId: wire.categoryId,
      title: wire.title,
      synopsis: wire.synopsis,
      chapterIds: wire.chapterIds,
      isPublished: isPublished,
      portraitImageAssetId: nil,
      portraitImageAsset: wire.portraitImageAsset.flatMap(Asset.init(wire:)),
      landscapeImageAssetId: wire.landscapeImageAsset?.assetId,
      landscapeImageAsset: wire.landscapeImageAsset.flatMap(Asset.init(wire:)),
      squareImageAssetId: wire.squareImageAsset?.assetId,
      squareImageAsset: wire.squareImageAsset.flatMap(Asset.init(wire:)),
      stats: wire.storyStats.flatMap(StoryStats.init(wire:))
    )
  }
}

public struct WireUserToStory: Codable {
  public let liked: Bool
  public let hide: Bool
  public let reported: Bool
}

public extension MutableUserToStory {
  init(wire: WireUserToStory) {
    self.init(isLiked: wire.liked, isHidden: wire.hide, isReported: wire.reported)
  }
}

public struct WireStoryStats: Codable {
  public let views: Int?
  public let reportCount: Int?
  public let likes: Int?
}

public extension StoryStats {
  init(wire: WireStoryStats) {
    self.init(
      likes: wire.likes ?? 0,
      reportCount: wire.reportCount ?? 0,
      views: wire.views ?? 0
    )
  }
}
