//
//  NetworkManager.swift
//  Fable
//
//  Created by Andrew Aquino on 4/10/19.
//

import Alamofire
import AppFoundation
import FableSDKModelObjects
import FableSDKResourceTargets
import Foundation
import Interface
import NetworkFoundation
import ReactiveSwift

public protocol NetworkManager: NetworkCoreProtocol, NetworkCoreDelegate {}
  
public extension NetworkManager {
  func request<T>(_ target: T) -> SignalProducer<T.ResponseBodyType?, NetworkError> where T: ResourceTargetProtocol {
    self.request(target, parameters: nil)
  }
  
  func upload<T>(_ target: T) -> SignalProducer<T.ResponseBodyType?, NetworkError> where T : ResourceTargetProtocol {
    self.upload(target, parameters: nil)
  }
}

public class NetworkManagerImpl: NetworkManager {
  private let environmentManager: EnvironmentManager
  public init(
    environmentManager: EnvironmentManager
  ) {
    self.environmentManager = environmentManager
  }
}


extension NetworkManagerImpl {
  public func networkCore<T>(networkEnvironment forResourceTarget: T) -> NetworkEnvironment where T: ResourceTargetProtocol {
    let environment = environmentManager.environment
    let authState = environmentManager.authState
    return FableNetworkEnvironment.generateEnvironment(
      environment: environment,
      authState: authState
    )
  }
}


extension NetworkManagerImpl {
  public func upload<T>(_ target: T, parameters: T.RequestBodyType? = nil) -> SignalProducer<T.ResponseBodyType?, NetworkError> where T: ResourceTargetProtocol {
    NetworkCore.upload(target, parameters: parameters, delegate: self)
  }

  public func request<T>(_ target: T, parameters: T.RequestBodyType? = nil) -> SignalProducer<T.ResponseBodyType?, NetworkError> where T: ResourceTargetProtocol {
    NetworkCore.request(target, parameters: parameters, delegate: self)
  }
}
