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

public class ConfigManager {
  private let networkManager: NetworkManager
  private let networkManagerV2: NetworkManagerV2
  private let stateManager: StateManager
  private let environmentManager: EnvironmentManager
  
  public init(
    networkManager: NetworkManager,
    networkManagerV2: NetworkManagerV2,
    environmentManager: EnvironmentManager,
    stateManager: StateManager
  ) {
    self.networkManager = networkManager
    self.networkManagerV2 = networkManagerV2
    self.environmentManager = environmentManager
    self.stateManager = stateManager
    refreshConfig()
  }

  public func refreshConfigV2() -> AnyPublisher<Config?, Exception> {
    self.networkManagerV2.request(GetConfig()).mapException().map { wire in
      if let config = wire.flatMap(Config.init(wire:)) {
        return config
      }
      return nil
    }.eraseToAnyPublisher()
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
