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
        "Application-API-Key": nil,
        "Authorization": authState.flatMap({ "Bearer \($0.accessToken)" }),
      ].compactMapValues { $0 }
    )
  }
}


extension NetworkManagerV2 {
  public func upload<T>(_ target: T, parameters: T.RequestBodyType? = nil) -> AnyPublisher<T.ResponseBodyType?, Exception> where T: ResourceTargetProtocol {
    NetworkCoreV2.upload(target, parameters: parameters, delegate: self)
  }
  
  public func request<T>(_ target: T, parameters: T.RequestBodyType? = nil) -> AnyPublisher<T.ResponseBodyType?, Exception> where T: ResourceTargetProtocol {
    NetworkCoreV2.request(target, parameters: parameters, delegate: self)
  }
}
