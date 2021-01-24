//
//  GetUserMe.swift
//  FableSDKResourceTargets
//
//  Created by Andrew Aquino on 1/8/20.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct GetUserMe: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireUser

  public let method: ResourceTargetHTTPMethod = .get
  public let url: String

  public init() {
    self.url = "/user/me"
  }
}
