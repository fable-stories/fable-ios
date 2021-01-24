//
//  GetCategories.swift
//  Fable
//
//  Created by Andrew Aquino on 8/21/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct GetCategories: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireCollection<WireKategory>

  public let method: ResourceTargetHTTPMethod = .get
  public let url: String = "/category"

  public init() {}
}
