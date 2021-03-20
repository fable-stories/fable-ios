//
//  ConfigManager.swift
//  Fable
//
//  Created by Andrew Aquino on 8/27/19.
//

import AppFoundation
import FableSDKModelObjects
import FableSDKResourceTargets
import Foundation
import Interface
import NetworkFoundation
import ReactiveSwift
import Combine
import FableSDKWireObjects
import FableSDKFoundation

public enum ConfigManagerEvent: EventContext {
  case didFailWithError(Error)
}

public protocol ConfigManager {
  func refreshConfig()
  func refreshConfigV2() -> AnyPublisher<Config?, Exception>
  
  var initialLaunchConfig: CurrentValueSubject<LaunchConfigState, Exception> { get }
}

public enum LaunchConfigState: Equatable {
  case received(Config)
  case receivedNone
  case unknown
  public static func == (lhs: LaunchConfigState, rhs: LaunchConfigState) -> Bool {
    switch (lhs, rhs) {
    case (.unknown, .unknown), (.receivedNone, .receivedNone), (.received, .received): return true
    default: return false
    }
  }
}

public class ConfigManagerImpl: ConfigManager {
  private let networkManager: NetworkManager
  private let networkManagerV2: NetworkManagerV2
  private let stateManager: StateManager
  private let environmentManager: EnvironmentManager
  private let eventManager: EventManager
  
  public let initialLaunchConfig: CurrentValueSubject<LaunchConfigState, Exception>

  public init(
    networkManager: NetworkManager,
    networkManagerV2: NetworkManagerV2,
    environmentManager: EnvironmentManager,
    stateManager: StateManager,
    eventManager: EventManager
  ) {
    self.networkManager = networkManager
    self.networkManagerV2 = networkManagerV2
    self.environmentManager = environmentManager
    self.stateManager = stateManager
    self.eventManager = eventManager
    self.initialLaunchConfig = CurrentValueSubject<LaunchConfigState, Exception>(.unknown)
  }

  public func refreshConfigV2() -> AnyPublisher<Config?, Exception> {
    self.networkManagerV2.request(
      path: "/config",
      method: .get
    ).map { [weak self] (wire: WireConfig) in
      guard let self = self else { return nil }
      if let config = Config(wire: wire) {
        if self.initialLaunchConfig.value == .unknown {
          self.initialLaunchConfig.value = .received(config)
        }
        return config
      }
      if self.initialLaunchConfig.value == .unknown {
        self.initialLaunchConfig.value = .receivedNone
      }
      return nil
    }.eraseToAnyPublisher().mapException().alsoOnError { [weak self] error in
      self?.eventManager.sendEvent(ConfigManagerEvent.didFailWithError(error))
    }
  }

  public func refreshConfig() {
    networkManager.request(
      GetConfig()
    )
    .on(failed: { _ in
    }, value: { [weak self] wire in
      guard let self = self, let wire = wire else { return }
      self.stateManager.modifyState { state in
        if let config = Config(wire: wire) {
          state.config = config
        }
      }
      }).start()
  }
}
