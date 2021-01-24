//
//  UpdateStory.swift
//  Fable
//
//  Created by Andrew Aquino on 8/18/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct UpdateStoryRequestBody: Codable {
  public let categoryId: Int?
  public let title: String?
  public let synopsis: String?
  public let published: Bool?
  public let portraitImageAssetId: Int?
  public let landscapeImageAssetId: Int?
  public let squareImageAssetId: Int?
  public init(
    categoryId: Int? = nil,
    title: String? = nil,
    synopsis: String? = nil,
    published: Bool? = nil,
    portraitImageAssetId: Int? = nil,
    landscapeImageAssetId: Int? = nil,
    squareImageAssetId: Int? = nil
  ) {
    self.categoryId = categoryId
    self.title = title
    self.synopsis = synopsis
    self.published = published
    self.portraitImageAssetId = portraitImageAssetId
    self.landscapeImageAssetId = landscapeImageAssetId
    self.squareImageAssetId = squareImageAssetId
  }
}

public struct UpdateStory: ResourceTargetProtocol {
  public typealias RequestBodyType = UpdateStoryRequestBody
  public typealias ResponseBodyType = EmptyResponseBody

  public let method: ResourceTargetHTTPMethod = .put
  public let url: String

  public init(storyId: Int) {
    self.url = "/story/\(storyId)"
  }
}
