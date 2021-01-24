//
//  RefreshModifiersByStoryId.swift
//  FableSDKResourceTargets
//
//  Created by Andrew Aquino on 7/16/20.
//

import AppFoundation
import FableSDKWireObjects
import NetworkFoundation

public struct RefreshModifiersByStoryId: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireCollection<WireModifier>
  
  public let method: ResourceTargetHTTPMethod = .get
  public let url: String
  
  public init(storyId: Int) {
    self.url = "/story/\(storyId)/modifier"
  }
}
