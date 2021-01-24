//
//  Action+Extensions.swift
//  ReactiveFoundation
//
//  Created by Andrew Aquino on 8/17/19.
//

import Foundation
import ReactiveSwift

extension ActionError {
  public var producerFailedError: Error? {
    switch self {
    case .disabled: return nil
    case let .producerFailed(error): return error
    }
  }
}
