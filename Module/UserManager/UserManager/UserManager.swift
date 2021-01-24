//
//  UserSessionManager.swift
//  App
//
//  Created by Andrew Aquino on 2/18/19.
//

import Foundation
import EnvironmentManager

public protocol UserProtocol {
  var userId: String { get }
  var email: String? { get }
  var password: String? { get }
  var providerId: String? { get }
  var providerUserId: String? { get }
  init(userId: String,
       email: String?,
       password: String?,
       providerId: String?,
       providerUserId: String?
  )
}
