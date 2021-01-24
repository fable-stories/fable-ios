//
//  GetDraftStories.swift
//  Fable
//
//  Created by Andrew Aquino on 11/25/19.
//

import AppFoundation
import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct GetDraftStories: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireCollection<WireStory>

  public let method: ResourceTargetHTTPMethod = .get
  public let url: String = "/creator/draft/story"

  public init() {}
}
