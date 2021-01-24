//
//  RefreshCategories.swift
//  FableSDKResourceTargets
//
//  Created by Andrew Aquino on 7/5/20.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct RefreshCategories: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireCollection<WireKategory>

  public let method: ResourceTargetHTTPMethod = .get
  public let url: String = "/category"

  public init() {}
}
