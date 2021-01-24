//
//  UpdateDraftCharacter.swift
//  Fable
//
//  Created by Andrew Aquino on 11/25/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct UpdateCharacterRequestBody: Codable {
  public let name: String?
  public let colorHexString: String?
  public let messageAlignment: String?
  
  public init(name: String?, colorHexString: String?, messageAlignment: String?) {
    self.name = name
    self.colorHexString = colorHexString
    self.messageAlignment = messageAlignment
  }
}

public struct UpdateDraftCharacter: ResourceTargetProtocol {
  public typealias RequestBodyType = UpdateCharacterRequestBody
  public typealias ResponseBodyType = EmptyResponseBody

  public let method: ResourceTargetHTTPMethod = .put
  public let url: String

  public init(characterId: Int) {
    self.url = "/character/\(characterId)"
  }
}
