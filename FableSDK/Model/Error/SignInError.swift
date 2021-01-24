//
//  SignInError.swift
//  Fable
//
//  Created by Andrew Aquino on 12/13/19.
//

import AppFoundation
import Foundation

public enum SignInError: Error {
  case networkError(NetworkError)
  case invalidResponseError
}

extension SignInError: Alertable {
  public var localizedTitle: String {
    "Sign In Error"
  }

  public var localizedDescription: String {
    switch self {
    case let .networkError(error): return error.localizedDescription
    case .invalidResponseError: return "Invalid response"
    }
  }
}
