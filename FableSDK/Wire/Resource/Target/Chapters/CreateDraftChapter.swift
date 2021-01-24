//
//  CreateDraftChapter.swift
//  Fable
//
//  Created by Andrew Aquino on 11/25/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct CreateDraftChapter: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireChapter

  public let method: ResourceTargetHTTPMethod = .post
  public let url: String

  public init(storyId: Int) {
    self.url = "/creator/story/\(storyId)/chapters"
  }
}
