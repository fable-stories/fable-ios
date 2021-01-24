//
//  EnvironmentManager.swift
//  Fable
//
//  Created by Andrew Aquino on 12/13/19.
//

import AppFoundation
import Foundation
import ReactiveSwift
import FableSDKModelObjects

public protocol EnvironmentManagerDelegate: AnyObject {
  var environment: Environment { get }
  var authState: AuthState? { get }
  func environmentManager(setEnvironment environment: Environment)
}


public struct EnvironmentManager {
  private let initialEnvironment: Environment
  private let initialUserId: Int?

  public var environment: Environment {
    delegate?.environment ?? initialEnvironment
  }
  
  public var authState: AuthState? {
    delegate?.authState
  }

  private weak var delegate: EnvironmentManagerDelegate?

  public let onUpdate: Signal<Void, Never>
  private let onUpdateObserver: Signal<Void, Never>.Observer

  public init(environment: Environment, userId: Int?) {
    (self.onUpdate, self.onUpdateObserver) = Signal<Void, Never>.pipe()
    self.initialEnvironment = environment
    self.initialUserId = userId
  }

  public init(delegate: EnvironmentManagerDelegate) {
    (self.onUpdate, self.onUpdateObserver) = Signal<Void, Never>.pipe()
    self.delegate = delegate
    self.initialEnvironment = delegate.environment
    self.initialUserId = delegate.authState?.userId
  }
  
  public func setEnvironment(_ environment: Environment) {
    self.delegate?.environmentManager(setEnvironment: environment)
  }
}
