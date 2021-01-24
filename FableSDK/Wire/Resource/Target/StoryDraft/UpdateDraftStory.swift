//
//  UpdateStoryDraft.swift
//  Fable
//
//  Created by Andrew Aquino on 11/25/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct UpdateStoryDraft: ResourceTargetProtocol {
  public typealias RequestBodyType = WireStory
  public typealias ResponseBodyType = WireStory

  public let method: ResourceTargetHTTPMethod = .put
  public let url: String

  public init(storyId: Int) {
    self.url = "/creator/story/\(storyId)"
  }
}
