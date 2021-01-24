//
//  RefreshMessages.swift
//  Fable
//
//  Created by Andrew Aquino on 8/24/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct RefreshMessages: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireCollection<WireMessage>

  public let method: ResourceTargetHTTPMethod = .get
  public let url: String

  public init(chapterId: Int) {
    self.url = "/chapter/\(chapterId)/message"
  }
}
