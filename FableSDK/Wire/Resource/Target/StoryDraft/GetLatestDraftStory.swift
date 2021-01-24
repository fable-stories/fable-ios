//
//  GetLatestStoryDraft.swift
//  Fable
//
//  Created by Andrew Aquino on 11/25/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct GetLatestStoryDraft: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireStoryDraft

  public let method: ResourceTargetHTTPMethod = .get
  public let url: String

  public init(userId: Int) {
    self.url = "/user/\(userId)/draft/story/latest"
  }
  
  public init(storyId: Int) {
    self.url = "/draft/story/\(storyId)/latest"
  }
}
