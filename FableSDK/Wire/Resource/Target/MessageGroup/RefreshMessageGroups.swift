//
//  RefreshMessageGroups.swift
//  Fable
//
//  Created by Andrew Aquino on 12/22/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct RefreshMessageGroups: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireCollection<WireMessageGroup>

  public let method: ResourceTargetHTTPMethod = .get
  public let url: String

  public init(chapterId: Int) {
    self.url = "/chapter/\(chapterId)/messageGroup"
  }
}
