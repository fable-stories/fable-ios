//
//  EditEventProtocol.swift
//  FableSDKViewPresenters
//
//  Created by Andrew Aquino on 9/13/20.
//

import Foundation
import AppFoundation

public let normalEditSessionId = randomUUIDString()

public protocol EditEventProtocol {
  var sessionId: String { get }
}

public extension Array where Element == EditEvent {
  func editEvents(sessionId: String, matching: Bool = true) -> [EditEvent] {
    filter { matching ? $0.sessionId == sessionId : $0.sessionId != sessionId }
  }
}
