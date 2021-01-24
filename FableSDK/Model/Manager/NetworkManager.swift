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
    return FableNetworkEnvironment(
      environment: environment,
      scheme: {
        switch environment {
        case .local: return "http"
        case .dev, .stage, .prod: return "https"
        case .proxy(let url): return url.toURL()?.scheme ?? ""
        }
      }(),
      host: {
        switch environment {
        case .local: return "localhost"
        case .dev: return "fable-dev-api-qbl24wgkba-uw.a.run.app"
        case .stage: return "app-api-deployable-zrcyfwwylq-uc.a.run.app"
        case .prod: return "app-api-deployable-m24edid2pa-uc.a.run.app"
        case .proxy(let url): return url.toURL()?.host ?? ""
        }
      }(),
      port: {
        switch environment {
        case .local: return 8080
        case .dev, .stage, .prod: return nil
        case .proxy(let url): return url.toURL()?.port
        }
      }(),
      path: {
        switch environment {
        case .local: return ""
        case .dev, .stage, .prod: return ""
        case .proxy(let url): return url.toURL()?.path ?? ""
        }
      }(),
      headers: [
        "Application-Platform": "ios",
        "Application-Environment": environment.description,
        "Application-Version": AppBuildSource.appVersion(),
        "Application-Build": AppBuildSource.appBuild(),
        "Authorization": authState.flatMap({ "Bearer \($0.accessToken)" }),
      ].compactMapValues { $0 }
    )
  }}


extension NetworkManagerImpl {
  public func upload<T>(_ target: T, parameters: T.RequestBodyType? = nil) -> SignalProducer<T.ResponseBodyType?, NetworkError> where T: ResourceTargetProtocol {
    NetworkCore.upload(target, parameters: parameters, delegate: self)
  }

  public func request<T>(_ target: T, parameters: T.RequestBodyType? = nil) -> SignalProducer<T.ResponseBodyType?, NetworkError> where T: ResourceTargetProtocol {
    NetworkCore.request(target, parameters: parameters, delegate: self)
  }
}

public struct FableNetworkEnvironment: NetworkEnvironment {
  public let environment: Environment
  public let scheme: String
  public let host: String
  public let port: Int?
  public let path: String
  public let headers: [String: String]

  public init(environment: Environment, scheme: String, host: String, port: Int?, path: String, headers: [String: String]) {
    self.environment = environment
    self.scheme = scheme
    self.host = host
    self.port = port
    self.path = path
    self.headers = headers
  }
}
