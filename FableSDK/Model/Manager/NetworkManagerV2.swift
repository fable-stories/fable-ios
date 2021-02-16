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
  
  public func networkCore(
    networkEnvironment path: String,
    method: ResourceTargetHTTPMethod
  ) -> NetworkEnvironment {
    let environment = environmentManager.environment
    let authState = environmentManager.authState
    return FableNetworkEnvironment.generateEnvironment(
      environment: environment,
      authState: authState
    )
  }
}


extension NetworkManagerV2 {
  public func upload<T>(
    path: String,
    method: ResourceTargetHTTPMethod,
    multipartFormData: @escaping (MultiPartFormDataProtocol) -> Void,
    expect: T.Type = T.self
  ) -> AnyPublisher<T, Exception> where T : Decodable, T : Encodable {
    NetworkCoreV2.upload(
      path: path,
      method: method,
      parameters: EmptyParameters(),
      multipartFormData: multipartFormData,
      expect: expect,
      delegate: self
    )
  }
  
  public func upload<T, V>(
    path: String,
    method: ResourceTargetHTTPMethod,
    parameters: V?,
    multipartFormData: @escaping (MultiPartFormDataProtocol) -> Void,
    expect: T.Type = T.self
  ) -> AnyPublisher<T, Exception> where T : Decodable, T : Encodable, V : Decodable, V : Encodable {
    NetworkCoreV2.upload(
      path: path,
      method: method,
      parameters: parameters,
      multipartFormData: multipartFormData,
      expect: expect,
      delegate: self
    )
  }
  
  public func request<T>(
    path: String,
    method: ResourceTargetHTTPMethod,
    expect: T.Type = T.self
  ) -> AnyPublisher<T, Exception> where T : Decodable, T : Encodable {
    self.request(
      path: path,
      method: method,
      parameters: EmptyParameters(),
      expect: expect
    )
  }
  
  public func request<T, V>(
    path: String,
    method: ResourceTargetHTTPMethod,
    parameters: V?,
    expect: T.Type = T.self
  ) -> AnyPublisher<T, Exception> where T : Decodable, T : Encodable, V : Decodable, V : Encodable {
    NetworkCoreV2.request(
      path: path,
      method: method,
      parameters: parameters,
      expect: expect,
      delegate: self
    )
    .mapError { error in
      RemoteLogger.shared.log(error)
      return error
    }
    .eraseToAnyPublisher()
  }
}

private class EmptyParameters: Codable {}
