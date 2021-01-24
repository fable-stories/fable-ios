//
//  DeleteStoryDraft.swift
//  Fable
//
//  Created by Andrew Aquino on 11/25/19.
//

import Foundation
import NetworkFoundation

public struct DeleteStoryDraft: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = EmptyResponseBody

  public let method: ResourceTargetHTTPMethod = .delete
  public let url: String

  public init(storyId: Int) {
    self.url = "/story/\(storyId)"
  }
}
