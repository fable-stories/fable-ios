//
//  RKModelManager.swift
//  Fable
//
//  Created by Andrew Aquino on 12/22/19.
//

import AppFoundation
import FableSDKModelObjects
import FableSDKResourceManagers
import FableSDKResourceTargets
import Foundation
import ReactiveSwift


public class RKModelManager {
  public let onUpdate: Signal<Void, Never>
  private let onUpdateObserver: Signal<Void, Never>.Observer

  private var model: DataStore
  private let networkManager: NetworkManager
  private let resourceManager: ResourceManager

  public init(
    model: DataStore,
    networkManager: NetworkManager,
    resourceManager: ResourceManager
  ) {
    self.model = model
    self.networkManager = networkManager
    self.resourceManager = resourceManager
    (self.onUpdate, self.onUpdateObserver) = Signal<Void, Never>.pipe()
  }

}
