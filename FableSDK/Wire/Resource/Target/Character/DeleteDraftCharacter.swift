//
//  DeleteDraftCharacter.swift
//  Fable
//
//  Created by Andrew Aquino on 11/25/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct DeleteDraftCharacter: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = EmptyResponseBody

  public let method: ResourceTargetHTTPMethod = .delete
  public let url: String

  public init(characterId: Int) {
    self.url = "/character/\(characterId)"
  }
}
