//
//  DeleteDraftMessageGroup.swift
//  Fable
//
//  Created by Andrew Aquino on 11/25/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct DeleteDraftMessageGroup: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireMessageGroup

  public let method: ResourceTargetHTTPMethod = .delete
  public let url: String

  public init(storyId: Int, chapterId: Int, messageGroupId: Int) {
    self.url = "/creator/story/\(storyId)/chapter/\(chapterId)/messageGroup/\(messageGroupId)"
  }
}
