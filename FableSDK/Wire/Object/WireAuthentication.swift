//
//  WireAuthentication.swift
//  Fable
//
//  Created by Andrew Aquino on 12/13/19.
//

import AppFoundation
import Foundation

public struct WireAuthentication: Codable, InitializableWireObject {
  public let idToken: String?
  public let refreshToken: String?
  public let expiresIn: String?
  public let isNewUser: Bool?
}

public struct SignInRequest: Codable, InitializableWireObject {
  public let email: String?
  public let password: String?
  public let refreshToken: String?
}

public struct GoogleSignInRequest: Codable, InitializableWireObject {
  public let rawIdToken: String?
}

public struct SignInResponse: Codable, InitializableWireObject {
  public let authentication: WireAuthentication?
  public let user: WireUser?
}

public struct WireAuthenticationResponse: Codable {
  public let accessToken: String?
  public let user: WireUser?
}
