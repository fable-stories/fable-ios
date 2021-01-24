//
//  SignInWithGoogle.swift
//  FableSDKResourceTargets
//
//  Created by Andrew Aquino on 6/26/20.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct SignInWithGoogle: ResourceTargetProtocol {
  public typealias RequestBodyType = GoogleSignInRequest
  public typealias ResponseBodyType = WireAuthenticationResponse

  public let method: ResourceTargetHTTPMethod = .post
  public let url: String

  public init() {
    self.url = "/auth/google"
  }
}
