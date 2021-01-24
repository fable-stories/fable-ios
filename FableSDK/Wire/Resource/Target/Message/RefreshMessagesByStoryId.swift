//
//  RefreshMessagesByStoryId.swift
//  FableSDKResourceTargets
//
//  Created by Andrew Aquino on 7/5/20.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct RefreshMessagesByStoryId: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireCollection<WireMessage>

  public let method: ResourceTargetHTTPMethod = .get
  public let url: String

  public init(storyId: Int) {
    self.url = "/story/\(storyId)/message"
  }
}
