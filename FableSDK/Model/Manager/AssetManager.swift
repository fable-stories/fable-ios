//
//  AssetManager.swift
//  FableSDKModelManagers
//
//  Created by Andrew Aquino on 12/17/20.
//

import Foundation
import Combine
import AppFoundation
import FableSDKResourceTargets
import FableSDKModelObjects
import FableSDKWireObjects

public protocol AssetManager {
  func uploadAsset(asset: Data, fileName: String, tags: [String]) -> AnyPublisher<Asset?, Exception>
}

public class AssetManagerImpl: AssetManager {
  
  private let networkManager: NetworkManagerV2
  private let authManager: AuthManager
  
  public init(networkManager: NetworkManagerV2, authManager: AuthManager) {
    self.networkManager = networkManager
    self.authManager = authManager
  }
  
  public func uploadAsset(asset: Data, fileName: String, tags: [String]) -> AnyPublisher<Asset?, Exception> {
    guard let userId = authManager.authenticatedUserId else { return .singleValue(nil) }
    return self.networkManager.upload(
      path: "/user/\(userId)/asset",
      method: .post,
      multipartFormData: { form in
        form.append(asset, withName: "file", fileName: fileName, mimeType: asset.mimeType)
        form.append("ios", withName: "objectSouce")
        if tags.isNotEmpty {
          form.append(tags.joined(separator: ","), withName: "tags")
        }
      }
    )
    .mapException()
    .map { (wire: WireAsset?) -> Asset? in
      if let asset = wire.flatMap(Asset.init(wire:)) {
        return asset
      }
      return nil
    }
    .eraseToAnyPublisher()
  }
}
