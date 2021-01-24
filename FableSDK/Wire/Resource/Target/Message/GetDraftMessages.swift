//
//  GetDraftMessages.swift
//  Fable
//
//  Created by Andrew Aquino on 11/25/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct GetDraftMessages: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireCollection<WireMessage>

  public let method: ResourceTargetHTTPMethod = .get
  public let url: String

  public init(messageGroupId: Int) {
    self.url = "/messageGroup/\(messageGroupId)/message"
  }

  public init(storyId: Int, chapterId: Int, messageGroupId: Int) {
    self.url = "/creator/story/\(storyId)/chapter/\(chapterId)/messageGroup/\(messageGroupId)/message"
  }
}
