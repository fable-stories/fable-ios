//
//  FableNetworkEnvironment.swift
//  FableSDKModelManagers
//
//  Created by Andrew Aquino on 1/24/21.
//

import Foundation
import NetworkFoundation
import FableSDKModelObjects
import AppFoundation

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
  
  public static func generateEnvironment(
    environment: Environment,
    authState: AuthState?
  ) -> FableNetworkEnvironment {
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
        "Application-Version": ApplicationMetadata.appVersion(),
        "Application-Build": ApplicationMetadata.appBuild(),
        "Application-API-Key": "9c97bf0e-c3d2-4ad5-a5f7-8a2a5c819469",
        "Application-Source": ApplicationMetadata.source().rawValue,
        "Authorization": authState.flatMap({ "Bearer \($0.accessToken)" }),
      ].compactMapValues { $0 }
    )

  }
}
