//
//  GetConfig.swift
//  Fable
//
//  Created by Andrew Aquino on 8/19/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct GetConfig: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireConfig

  public let method: ResourceTargetHTTPMethod = .get
  public let url: String = "/config"

  public init() {}
}
