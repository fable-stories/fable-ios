//
//  NetworkManager+Stub.swift
//  FableTests
//
//  Created by Andrew Aquino on 12/26/20.
//

import Foundation
import NetworkFoundation
import Combine
import AppFoundation
import FableSDKModelManagers
import FableSDKResourceTargets
import FableSDKModelObjects
import FableSDKWireObjects

struct Mock {
  static let user: WireUser = .init(userId: 1, firstName: "Bob", lastName: "Henry", userName: nil, email: "bob@email.com", password: "password", biography: nil, avatarAsset: nil, createdAt: Date.now.iso8601String)
}

public class TestNetworkManager: NetworkManagerV2 {
  private let environmentManager: EnvironmentManager
  
  public init(
    environmentManager: EnvironmentManager
  ) {
    self.environmentManager = environmentManager
  }

  public func networkCore<T>(networkEnvironment forResourceTarget: T) -> NetworkEnvironment where T : ResourceTargetProtocol {
    let environment = environmentManager.environment
    let authState = environmentManager.authState
    return FableNetworkEnvironment(
      environment: environment,
      scheme: {
        switch environment {
        case .local: return "http"
        case .stage, .prod: return "https"
        case .proxy(let url): return url.toURL()?.scheme ?? ""
        }
      }(),
      host: {
        switch environment {
        case .local: return "localhost"
        case .stage: return "app-api-deployable-zrcyfwwylq-uc.a.run.app"
        case .prod: return "app-api-deployable-m24edid2pa-uc.a.run.app"
        case .proxy(let url): return url.toURL()?.host ?? ""
        }
      }(),
      port: {
        switch environment {
        case .local: return 8080
        case .stage, .prod: return nil
        case .proxy(let url): return url.toURL()?.port
        }
      }(),
      path: {
        switch environment {
        case .local: return ""
        case .stage, .prod: return ""
        case .proxy(let url): return url.toURL()?.path ?? ""
        }
      }(),
      headers: [
        "Application-Platform": "ios",
        "Authorization": authState.flatMap({ "Bearer \($0.accessToken)" }),
      ].compactMapValues { $0 }
    )
  }
  
  public func networkCore<T>(stubRequest target: T, parameters: T.RequestBodyType?) -> AnyPublisher<T.ResponseBodyType?, Exception>? where T : ResourceTargetProtocol {
    switch target {
    case _ as GetUser:
      return .singleValue(Mock.user as? T.ResponseBodyType)
    default:
      break
    }
    return nil
  }
}
