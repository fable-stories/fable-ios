//
//  GetRecentDraftSession.swift
//  FableSDKResourceTargets
//
//  Created by Andrew Aquino on 12/25/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct GetRecentDraftSession: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireStory

  public let method: ResourceTargetHTTPMethod = .get
  public let url: String

  public init(userId: Int) {
    self.url = "/user/\(userId)/draft/story"
  }
}
