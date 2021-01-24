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
      UploadAssetRequest(
        userId: userId,
        file: asset,
        fileName: fileName,
        tags: tags
      )
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
