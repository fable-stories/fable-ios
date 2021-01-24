//
//  GlobalContextManager.swift
//  FableSDKInterface
//
//  Created by Andrew Aquino on 3/22/20.
//

import AppFoundation
import ReactiveFoundation
import ReactiveSwift
import FableSDKModelObjects

internal protocol GlobalAuthContext: AnyObject {
  func userId() -> Int?
  func changeUserId(_ userId: Int?)
}

public struct GlobalContext {
  public let userId: Int?
  public let environment: Environment
}


public class GlobalContextManager {
  fileprivate static var mutableCurrentEnvironment = PersistedProperty<Environment>(
    "GlobalContext.currentEnvironment",
    {
      switch AppBuildSource.source() {
      case .simulator: return .stage
      case .testFlight: return .prod
      case .appStore: return .prod
      }
    }()
  )

  fileprivate static let mutableCurrentAuthState = PersistedProperty<AuthState?>(
    "GlobalContext.currentAuthState",
    nil
  )

  private var currentGlobalContext: GlobalContext {
    GlobalContext(
      userId: GlobalContextManager.mutableCurrentAuthState.value?.userId,
      environment: GlobalContextManager.mutableCurrentEnvironment.value
    )
  }

  public let onUpdate: Signal<Void, Never>
  private let onUpdateObserver: Signal<Void, Never>.Observer

  public init() {
    (self.onUpdate, self.onUpdateObserver) = Signal<Void, Never>.pipe()
    if let envString = envString("env") {
      setEnvironment(Environment(rawValue: envString))
    } else {
      setEnvironment(Environment.stage)
    }
  }

  public func setEnvironment(_ environment: Environment) {
    GlobalContextManager.mutableCurrentEnvironment.value = environment
    setGlobalContextDidChange()
  }

  private func setAuthState(_ authState: AuthState?) {
    GlobalContextManager.mutableCurrentAuthState.value = authState
    setGlobalContextDidChange()
  }

  private func setGlobalContextDidChange() {
    onUpdateObserver.send(value: ())
  }
}


extension GlobalContextManager: EnvironmentManagerDelegate {
  public var environment: Environment {
    get { GlobalContextManager.mutableCurrentEnvironment.value }
    set { GlobalContextManager.mutableCurrentEnvironment.value = newValue }
  }
  public var authState: AuthState? { GlobalContextManager.mutableCurrentAuthState.value }

  public func environmentManager(setEnvironment environment: Environment) {
    self.setEnvironment(environment)
  }
}


extension GlobalContextManager: AuthManagerDelegate {
  public func authManager(authStateDidChange authState: AuthState?, authManager: AuthManager) {
    self.setAuthState(authState)
  }
}
