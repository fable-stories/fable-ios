//
//  IncrementStoryViewsResource.swift
//  FableSDKResourceTargets
//
//  Created by Andrew Aquino on 1/4/21.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct IncrementStoryViewsResource: ResourceTargetProtocol {
  public struct Response: Codable {
    public let views: Int
  }
  
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = Response
  
  public let method: ResourceTargetHTTPMethod = .post
  public let url: String
  
  public init(storyId: Int) {
    self.url = "/story/\(storyId)/stats/views"
  }
}
