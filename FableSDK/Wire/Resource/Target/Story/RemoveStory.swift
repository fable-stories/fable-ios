//
//  RemoveStory.swift
//  Fable
//
//  Created by Andrew Aquino on 12/24/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct RemoveStory: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireStory

  public let method: ResourceTargetHTTPMethod = .delete
  public let url: String

  public init(storyId: Int) {
    self.url = "/story/\(storyId)"
  }
}
