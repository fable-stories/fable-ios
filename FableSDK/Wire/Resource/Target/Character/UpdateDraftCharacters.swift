//
//  UpdateDraftCharacters.swift
//  Fable
//
//  Created by Andrew Aquino on 11/26/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct UpdateDraftCharacters: ResourceTargetProtocol {
  public typealias RequestBodyType = WireCollection<WireModifier>
  public typealias ResponseBodyType = WireCollection<WireModifier>

  public let method: ResourceTargetHTTPMethod = .put
  public let url: String

  public init(storyId: Int) {
    self.url = "/creator/story/\(storyId)/character"
  }
}
