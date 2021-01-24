//
//  AuthenticationContext.swift
//  Fable
//
//  Created by Andrew Aquino on 12/13/19.
//

import Foundation

public struct AuthenticationContext: Codable, Equatable {
  public let userId: Int
  public let email: String?
  public let password: String?

  public init?(
    userId: Int?,
    email: String?,
    password: String?
  ) {
    guard let userId = userId else { return nil }
    self.userId = userId
    self.email = email
    self.password = password
  }
}
