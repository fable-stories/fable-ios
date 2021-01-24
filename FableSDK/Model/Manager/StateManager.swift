//
//  StateManager.swift
//  FableSDKInterface
//
//  Created by Andrew Aquino on 2/10/20.
//

import AppFoundation
import FableSDKModelObjects
import Foundation
import ReactiveFoundation
import ReactiveSwift

public let kAuthenticationContextKey = "StateManager.authenticationContext"
public let kDataStorePropertyKey = "StateManager.datastore"


public protocol StateManagerReadOnly {
  func state() -> State
  var onUpdate: Signal<State, Never> { get }
}


public class StateManager: StateManagerReadOnly {
  private let environmentManager: EnvironmentManager

  public init(
    environmentManager: EnvironmentManager
  ) {
    self.environmentManager = environmentManager
    (self.onUpdate, self.onUpdateObserver) = Signal<State, Never>.pipe()
    // print out initial state
    Log(state)
  }

  // MARK: - Session State

  private lazy var mutableState = PersistedProperty<State>(
    kDataStorePropertyKey,
    State(appSessionId: randomUUIDString())
  )

  public let onUpdate: Signal<State, Never>
  private let onUpdateObserver: Signal<State, Never>.Observer

  public func state() -> State {
    mutableState.value
  }

  public func modifyState(_ block: (inout State) -> Void) {
    mutableState.modify(block)
    onUpdateObserver.send(value: state())
  }
}
