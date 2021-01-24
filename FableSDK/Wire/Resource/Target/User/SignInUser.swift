//
//  SignInUser.swift
//  Fable
//
//  Created by Andrew Aquino on 12/12/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct SignInUser: ResourceTargetProtocol {
  public typealias RequestBodyType = SignInRequest
  public typealias ResponseBodyType = WireAuthenticationResponse

  public let method: ResourceTargetHTTPMethod = .post
  public let url: String

  public init() {
    self.url = "/auth/email"
  }
}
