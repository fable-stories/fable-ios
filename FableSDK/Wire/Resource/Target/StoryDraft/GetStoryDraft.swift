//
//  GetStoryDraft.swift
//  FableSDKResourceTargets
//
//  Created by Andrew Aquino on 11/28/20.
//

import Foundation
import NetworkFoundation
import FableSDKWireObjects

public struct GetStoryDraft: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireStoryDraft
  
  public let method: ResourceTargetHTTPMethod = .get
  public let url: String
  
  public init(storyId: Int) {
    self.url = "/story/\(storyId)/draft"
  }
}
