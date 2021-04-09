//
//  AnalyticsManager.swift
//  FableSDKInterface
//
//  Created by Enrique Florencio on 7/30/20.
//

import Foundation
import FableSDKEnums
import Combine

/// The Analytics Manager should be able to flush, identify, and track events through the use of the Firebase SDK

public protocol AnalyticsManager {
  var onTrackEvent: PassthroughSubject<(AnalyticsEventIdentifiable, [String: Any]?), Never> { get }
  
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

  public let onTrackEvent: PassthroughSubject<(AnalyticsEventIdentifiable, [String : Any]?), Never>

  private var trackCount: Int = 0
  
  public init(networkManager: NetworkManager) {
    self.networkManager = networkManager
    self.onTrackEvent = PassthroughSubject<(AnalyticsEventIdentifiable, [String : Any]?), Never>()
  }
  
  public func flushData() {
  }
  
  public func identifyUser(userId: Int) {
  }
  
  public func trackEvent(_ event: AnalyticsEventIdentifiable, properties: [String : Any]?) {
    self.trackCount += 1
    self.onTrackEvent.send((event, properties))
    print("AnalyticEvent \(self.trackCount): \(event.rawValue)")
  }
}

