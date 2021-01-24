//
//  UpdateStoryParameters.swift
//  FableSDKModelObjects
//
//  Created by Andrew Aquino on 12/17/20.
//

import Foundation

public struct UpdateStoryParameters {
  public let categoryId: Int?
  public let title: String?
  public let synopsis: String?
  public let isPublished: Bool?
  public let portraitImageAssetId: Int?
  public let landscapeImageAssetId: Int?
  public let squareImageAssetId: Int?
  public init(
    categoryId: Int? = nil,
    title: String? = nil,
    synopsis: String? = nil,
    isPublished: Bool? = nil,
    portraitImageAssetId: Int? = nil,
    landscapeImageAssetId: Int? = nil,
    squareImageAssetId: Int? = nil
  ) {
    self.categoryId = categoryId
    self.title = title
    self.synopsis = synopsis
    self.isPublished = isPublished
    self.portraitImageAssetId = portraitImageAssetId
    self.landscapeImageAssetId = landscapeImageAssetId
    self.squareImageAssetId = squareImageAssetId
  }
}

public extension UpdateStoryParameters {
  func apply(story: MutableStory) {
    self.categoryId.flatMap { story.categoryId = $0 }
    self.title.flatMap { story.title = $0 }
    self.synopsis.flatMap { story.synopsis = $0 }
    self.isPublished.flatMap { story.isPublished = $0 }
    self.portraitImageAssetId.flatMap { story.portraitImageAssetId = $0 }
    self.landscapeImageAssetId.flatMap { story.landscapeImageAssetId = $0 }
    self.squareImageAssetId.flatMap { story.squareImageAssetId = $0 }
  }
}
