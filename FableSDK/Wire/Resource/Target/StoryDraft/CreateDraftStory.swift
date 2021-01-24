//
//  CreateStoryDraft.swift
//  FableSDKResourceTargets
//
//  Created by Andrew Aquino on 7/5/20.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct CreateStoryDraftRequestBody: Codable {
  public let userId: Int
  public let title: String
  public let description: String

  public init(userId: Int, title: String, description: String) {
    self.userId = userId
    self.title = title
    self.description = description
  }
}

public struct CreateStoryDraft: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireStoryDraft

  public let method: ResourceTargetHTTPMethod = .post
  public let url: String

  public init(userId: Int) {
    self.url = "/user/\(userId)/draft/story"
  }
}
