//
//  GetFeed.swift
//  Fable
//
//  Created by Andrew Aquino on 12/22/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct GetFeed: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireCollection<WireKategory>

  public let method: ResourceTargetHTTPMethod = .get
  public let url: String = "/mobile/feed"

  public init() {}
}
