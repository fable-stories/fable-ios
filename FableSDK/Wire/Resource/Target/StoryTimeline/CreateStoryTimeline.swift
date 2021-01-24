//
//  CreateStoryTimeline.swift
//  FableSDKResourceTargets
//
//  Created by Andrew Aquino on 7/17/20.
//

import AppFoundation
import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct CreateStoryTimeline: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireStoryTimeline
  
  public let method: ResourceTargetHTTPMethod = .post
  public let url: String
  
  public init(userId: Int, storyId: Int) {
    self.url = "/user/\(userId)/story/\(storyId)/timeline"
  }
}
