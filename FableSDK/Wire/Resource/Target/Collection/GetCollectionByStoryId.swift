//
//  GetCollectionByStoryId.swift
//  FableSDKResourceTargets
//
//  Created by Andrew Aquino on 12/27/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct GetCollectionByStoryId: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireRichCollection

  public let method: ResourceTargetHTTPMethod = .get
  public let url: String

  public init(storyId: Int) {
    self.url = "/collection/story/\(storyId)"
  }
}
