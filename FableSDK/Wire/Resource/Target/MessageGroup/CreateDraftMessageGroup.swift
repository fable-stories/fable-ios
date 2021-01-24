//
//  CreateDraftMessageGroup.swift
//  Fable
//
//  Created by Andrew Aquino on 11/25/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct CreateDraftMessageGroup: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireMessageGroup

  public let method: ResourceTargetHTTPMethod = .post
  public let url: String

  public init(storyId: Int, chapterId: Int) {
    self.url = "/creator/story/\(storyId)/chapter/\(chapterId)/messageGroup"
  }
}
