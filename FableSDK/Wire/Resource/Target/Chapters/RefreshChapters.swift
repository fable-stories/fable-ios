//
//  RefreshChapters.swift
//  Fable
//
//  Created by Andrew Aquino on 8/24/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct RefreshChapters: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireCollection<WireChapter>

  public let method: ResourceTargetHTTPMethod = .get
  public let url: String

  public init(storyId: Int) {
    self.url = "/story/\(storyId)/chapter"
  }
}
