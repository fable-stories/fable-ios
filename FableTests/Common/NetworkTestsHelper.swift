//
//  NetworkTestsHelper.swift
//  FableTests
//
//  Created by Steven Andrews on 2020-05-24.
//

import Foundation
import AppFoundation
import FableSDKResolver
import FableSDKResourceTargets
import FableSDKModelManagers
import Firebolt

class NetworkTestsHelper {
  static let shared = NetworkTestsHelper()
  static let expectationTimeout = 30.0 // timeout for async calls in seconds
  
  private let resolver = FBSDKResolver()
  
  private(set) lazy var networkManager: NetworkManager = resolver.get()
  private(set) lazy var networkManagerV2: TestNetworkManager = resolver.get()
  private(set) lazy var environmentManager: EnvironmentManager = resolver.get()

  private init() {
    self.resolver.register(expect: TestNetworkManager.self) { TestNetworkManager(environmentManager: $0.get()) }
  }
}
