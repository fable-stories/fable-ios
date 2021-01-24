//
//  UserProfileResource.swift
//  FableSDKResourceTargets
//
//  Created by Andrew Aquino on 12/27/20.
//

import Foundation
import FableSDKWireObjects
import NetworkFoundation

public struct UserProfileResource: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireUserProfile
  
  public let method: ResourceTargetHTTPMethod = .get
  public let url: String
  
  public init(userId: Int) {
    self.url = "/mobile/user/\(userId)/user-profile"
  }
}
