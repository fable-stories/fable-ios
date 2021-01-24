//
//  GetStory.swift
//  Fable
//
//  Created by Andrew Aquino on 11/25/19.
//

import AppFoundation
import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct GetStory: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireStory

  public let method: ResourceTargetHTTPMethod = .get
  public let url: String

  public init(storyId: Int) {
    self.url = "/story/\(storyId)"
  }
}
