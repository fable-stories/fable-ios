//
//  RemoveCharacterById.swift
//  FableSDKResourceTargets
//
//  Created by Andrew Aquino on 1/13/20.
//

import AppFoundation
import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct RemoveCharacterById: ResourceTargetProtocol {
  public typealias RequestBodyType = WireCollectionRemoveById
  public typealias ResponseBodyType = EmptyResponseBody

  public let method: ResourceTargetHTTPMethod = .delete
  public let url: String

  public init(characterId: Int) {
    self.url = "/character/\(characterId)"
  }
}
