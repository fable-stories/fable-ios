//
//  GetCharacterById.swift
//  FableSDKResourceTargets
//
//  Created by Andrew Aquino on 7/16/20.
//

import AppFoundation
import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct GetCharacterById: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireCharacter
  
  public let method: ResourceTargetHTTPMethod = .get
  public let url: String
  
  public init(characterId: Int) {
    self.url = "/character/\(characterId)"
  }
}
