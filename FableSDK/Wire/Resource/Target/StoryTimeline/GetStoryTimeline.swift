//
//  GetStoryTimeline.swift
//  Fable
//
//  Created by Andrew Aquino on 8/14/19.
//

import AppFoundation
import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct GetStoryTimeline: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireStoryTimeline

  public let method: ResourceTargetHTTPMethod = .get
  public let url: String
  
  public init(storyId: Int) {
    self.url = "/story/\(storyId)/timeline"
  }
}
