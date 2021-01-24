//
//  GetStories.swift
//  Fable
//
//  Created by Andrew Aquino on 8/14/19.
//

import AppFoundation
import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct GetStories: ResourceTargetProtocol {
  public typealias RequestBodyType = GetStoriesRequestBody
  public typealias ResponseBodyType = WireCollection<WireStory>

  public let method: ResourceTargetHTTPMethod = .get
  public let url: String = "/story"
  
  public init() {}
}

public struct GetStoriesRequestBody: Codable {
  public let visibility: String?

  public init(visibility: String? = nil) {
    self.visibility = visibility
  }
}
