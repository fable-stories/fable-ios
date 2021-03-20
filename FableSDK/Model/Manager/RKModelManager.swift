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
  
  private var userInfo: [String: String] = [:]

  private var paperTrailLogger: RMPaperTrailLogger?

  private init() {
    if let paperTrailLogger = RMPaperTrailLogger.sharedInstance() {
      paperTrailLogger.host = "logs5.papertrailapp.com"
      paperTrailLogger.port = 53487
      self.paperTrailLogger = paperTrailLogger
      self.paperTrailLogger?.machineName = "com.fable.stories"
      DDLog.add(paperTrailLogger)
    }
  }
  
  public func log( _ value: Any?) {
    guard let value = value else { return }
    DDLogVerbose(value)
  }
  
  public func addUserInfo(_ key: String, value: String) {
    self.userInfo[key] = value
    self.updateProgramName()
  }
  
  public func removeUserInfo(_ key: String) {
    self.userInfo[key] = nil
    self.updateProgramName()
  }
  
  private func updateProgramName() {
    let progrmaName = userInfo.values.sorted(by: >).joined(separator: ":")
    self.paperTrailLogger?.programName = progrmaName
  }
}
