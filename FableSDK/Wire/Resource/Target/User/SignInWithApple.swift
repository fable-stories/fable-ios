//
//  SignInWithApple.swift
//  FableSDKResourceTargets
//
//  Created by Andrew Aquino on 10/25/20.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct SignInWithApple: ResourceTargetProtocol {
  public struct Request: Codable {
    public let appleSub: String
    public let email: String
    public init(appleSub: String, email: String) {
      self.appleSub = appleSub
      self.email = email
    }
  }
  
  public typealias RequestBodyType = Request
  public typealias ResponseBodyType = WireAuthenticationResponse
  
  public let method: ResourceTargetHTTPMethod = .post
  public let url: String
  
  public init() {
    self.url = "/auth/apple"
  }
}
