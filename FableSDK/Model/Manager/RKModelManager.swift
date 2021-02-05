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
import PaperTrailLumberjack

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

public class RemoteLogger {
  public static let shared = RemoteLogger()
  
  public var isEnabled: Bool = false

  private init() {
    if let paperTrailLogger = RMPaperTrailLogger.sharedInstance() {
      paperTrailLogger.host = "logs5.papertrailapp.com"
      paperTrailLogger.port = 53487
      paperTrailLogger.machineName = Bundle.main.bundleIdentifier
      DDLog.add(paperTrailLogger)
    }
  }
  
  public func log(_ value: Any?) {
    guard let value = value else { return }
    DDLogVerbose(value)
  }
}
