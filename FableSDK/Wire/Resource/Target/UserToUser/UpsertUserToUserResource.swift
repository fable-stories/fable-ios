//
//  UpsertUserToUserResource.swift
//  FableSDKResourceTargets
//
//  Created by Andrew Aquino on 12/26/20.
//

import Foundation
import NetworkFoundation
import FableSDKWireObjects

public struct UpsertUserToUserResource: ResourceTargetProtocol {
  public struct Request: Codable {
    public let isFollowing: Bool
    public init(isFollowing: Bool) {
      self.isFollowing = isFollowing
    }
  }

  public typealias RequestBodyType = Request
  public typealias ResponseBodyType = EmptyResponseBody
  
  public let method: ResourceTargetHTTPMethod = .post
  public let url: String
  
  public init(userId: Int, toUserId: Int) {
    self.url = "/user/\(userId)/to/user/\(toUserId)"
  }
}
