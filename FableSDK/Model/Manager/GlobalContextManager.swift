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

private var mutableCurrentEnvironment = PersistedProperty<Environment>(
  currentEnvironmentKey,
  delegate: GlobalContextPropertyDelegate()
)

private let mutableCurrentAuthState = PersistedProperty<AuthState?>(
  authStateKey,
  nil
)

private let currentEnvironmentKey = "GlobalContext.currentEnvironment"
private let authStateKey = "GlobalContext.currentAuthState"

public class GlobalContextManager {
  public static let shared = GlobalContextManager()
  private var currentGlobalContext: GlobalContext {
    GlobalContext(
      userId: mutableCurrentAuthState.value?.userId,
      environment: mutableCurrentEnvironment.value
    )
  }

  public let onUpdate: Signal<Void, Never>
  private let onUpdateObserver: Signal<Void, Never>.Observer

  private init() {
    (self.onUpdate, self.onUpdateObserver) = Signal<Void, Never>.pipe()

    RemoteLogger.shared.addUserInfo("ENVIRONMENT", value: self.currentGlobalContext.environment.rawValue)
    RemoteLogger.shared.addUserInfo("APPLICATION_METADATA", value: ApplicationMetadata.source().rawValue)
  }

  public func setEnvironment(_ environment: Environment) {
    mutableCurrentEnvironment.value = environment
    RemoteLogger.shared.addUserInfo("ENVIRONMENT", value: environment.rawValue)
    setGlobalContextDidChange()
  }

  private func setAuthState(_ authState: AuthState?) {
    mutableCurrentAuthState.value = authState
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
    get { mutableCurrentEnvironment.value }
    set { mutableCurrentEnvironment.value = newValue }
  }
  public var authState: AuthState? { mutableCurrentAuthState.value }

  public func environmentManager(setEnvironment environment: Environment) {
    self.setEnvironment(environment)
  }
}


extension GlobalContextManager: AuthManagerDelegate {
  public func authManager(authStateDidChange authState: AuthState?, authManager: AuthManager) {
    self.setAuthState(authState)
  }
}

private class GlobalContextPropertyDelegate: PersistedPropertyDelegate {
  public func initialValue<T>(for key: String) throws -> T where T : Decodable, T : Encodable {
    switch key {
    case currentEnvironmentKey:
      if let environment = Environment.sourceEnvironment() as? T {
        return environment
      }
    default:
      break
    }
    throw Exception("Exhausted possible keys for property delegate")
  }
  
  func initialPersistedValue<T>(for key: String) throws -> T? where T : Decodable, T : Encodable {
    switch key {
    case currentEnvironmentKey:
      /// Override the persisted value if there is an active Env Var
      if let envString = envString("env"), let environment = Environment(rawValue: envString) as? T {
        return environment
      }
      return nil
    default:
      break
    }
    throw Exception("Exhausted possible keys for property delegate")
  }
}
