//
//  AnalyticsManager.swift
//  FableSDKInterface
//
//  Created by Enrique Florencio on 7/30/20.
//

import Foundation
import FableSDKEnums

public protocol AnalyticsManagerDelegate: class {
  func analyticsManager(firebaseTrackEvent event: String, parameters: [String: Any]?)
}

/// The Analytics Manager should be able to flush, identify, and track events through the use of the Firebase SDK

public protocol AnalyticsManager {
  func flushData()
  func identifyUser(userId: Int)
  func trackEvent(_ event: AnalyticsEventIdentifiable, properties: [String: Any]?)
}

public extension AnalyticsManager {
  func trackEvent(_ event: AnalyticsEventIdentifiable) {
    self.trackEvent(event, properties: nil)
  }
}

/// Implements the AnalyticsManager protocol

public class AnalyticsManagerImpl: AnalyticsManager {
  private let networkManager: NetworkManager
  private weak var delegate: AnalyticsManagerDelegate?
  
  private var trackCount: Int = 0
  
  public init(networkManager: NetworkManager, delegate: AnalyticsManagerDelegate) {
    self.networkManager = networkManager
    self.delegate = delegate
  }
  
  public func flushData() {
  }
  
  public func identifyUser(userId: Int) {
  }
  
  public func trackEvent(_ event: AnalyticsEventIdentifiable, properties: [String : Any]?) {
    self.delegate?.analyticsManager(firebaseTrackEvent: event.rawValue, parameters: properties)
    self.trackCount += 1
    print("AnalyticEvent \(self.trackCount): \(event.rawValue)")
  }
}

