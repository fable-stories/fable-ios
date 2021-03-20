//
//  EventManager.swift
//  FableSDKInterface
//
//  Created by Andrew Aquino on 1/15/20.
//

import AppFoundation
import FableSDKFoundation
import FableSDKErrorObjects
import Foundation
import ReactiveSwift
import Combine

public struct EventIdentifier: Equatable {
  public let identifier: String
  public init(_ identifier: String) {
    self.identifier = identifier
  }
}

public enum EventKind: Equatable {
  case onError(Error)
  case onUpdate(EventIdentifier = EventIdentifier("NOOP"))

  public static func == (lhs: EventKind, rhs: EventKind) -> Bool {
    switch (lhs, rhs) {
    case let (.onError(lhsError), .onError(rhsError)):
      return lhsError.localizedDescription == rhsError.localizedDescription
    case let (.onUpdate(lhsEventIdentifier), .onUpdate(rhsEventIdentifier)):
      return lhsEventIdentifier == rhsEventIdentifier
    default:
      return false
    }
  }
}

public struct EventSource: Equatable {
  public let source: String
  public init(_ source: String) {
    self.source = source
  }
}


public class EventManager {
  private let remoteLogger = RemoteLogger.shared
  
  private let _onEvent = PassthroughSubject<EventContext, Exception>()
  public private(set) lazy var onEvent = _onEvent.eraseToAnyPublisher()
  
  private var eventCount: Int = 0
  
  private let environmentManager: EnvironmentManager

  public init(environmentManager: EnvironmentManager) {
    self.environmentManager = environmentManager
  }

  public func sendEvent(_ event: EventContext) {
    self.remoteLogger.log(event)
    self.eventCount += 1
    print("Event \(self.eventCount): \(event)")
    _onEvent.send(event)
  }
}
