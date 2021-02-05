//
//  NetworkManagerV2.swift
//  FableSDKModelManagers
//
//  Created by Andrew Aquino on 11/28/20.
//

import Alamofire
import AppFoundation
import FableSDKModelObjects
import FableSDKResourceTargets
import Foundation
import Interface
import NetworkFoundation
import ReactiveSwift
import Combine


public protocol NetworkManagerV2: NetworkCoreV2Protocol, NetworkCoreV2Delegate {
}


public class NetworkManagerV2Impl: NetworkManagerV2 {
  private let environmentManager: EnvironmentManager
  
  public init(
    environmentManager: EnvironmentManager
  ) {
    self.environmentManager = environmentManager
  }
  
  public func networkCore<T>(networkEnvironment forResourceTarget: T) -> NetworkEnvironment where T: ResourceTargetProtocol {
    let environment = environmentManager.environment
    let authState = environmentManager.authState
    return FableNetworkEnvironment.generateEnvironment(
      environment: environment,
      authState: authState
    )
  }
}


extension NetworkManagerV2 {
  public func upload<T>(_ target: T, parameters: T.RequestBodyType? = nil) -> AnyPublisher<T.ResponseBodyType?, Exception> where T: ResourceTargetProtocol {
    NetworkCoreV2.upload(target, parameters: parameters, delegate: self)
  }
  
  public func request<T>(_ target: T, parameters: T.RequestBodyType? = nil) -> AnyPublisher<T.ResponseBodyType?, Exception> where T: ResourceTargetProtocol {
    NetworkCoreV2.request(target, parameters: parameters, delegate: self)
      .mapError { error in
        RemoteLogger.shared.log(error)
        return error
      }
      .eraseToAnyPublisher()
  }
}
