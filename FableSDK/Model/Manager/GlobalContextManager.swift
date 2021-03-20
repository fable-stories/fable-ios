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
      switch ApplicationMetadata.source() {
      case .appStore: return .prod
      case .adHoc, .testFlight: return .dev
      case .simulator: return .local
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
    }
    
    RemoteLogger.shared.addUserInfo("ApplicationMetadata", value: ApplicationMetadata.source().rawValue)
  }

  public func setEnvironment(_ environment: Environment) {
    GlobalContextManager.mutableCurrentEnvironment.value = environment
    RemoteLogger.shared.addUserInfo("ENVIRONMENT", value: environment.description)
    setGlobalContextDidChange()
  }

  private func setAuthState(_ authState: AuthState?) {
    GlobalContextManager.mutableCurrentAuthState.value = authState
    if let authState = authState {
      RemoteLogger.shared.addUserInfo("AUTH_STATE", value: authState.userId.toString())
    } else {
      RemoteLogger.shared.removeUserInfo("AUTH_STATE")
    }
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
