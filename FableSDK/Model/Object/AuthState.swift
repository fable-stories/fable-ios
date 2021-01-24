//
//  AuthState.swift
//  FableSDKModelObjects
//
//  Created by Andrew Aquino on 12/24/20.
//

import Foundation

public struct AuthState: Codable {
  public let userId: Int
  public let accessToken: String
  public init(userId: Int, accessToken: String) {
    self.userId = userId
    self.accessToken = accessToken
  }
}
