//
//  GetSingleCategory.swift
//  FableSDKResourceTargets
//
//  Created by Enrique Florencio on 7/10/20.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct GetSingleCategory: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireKategory

  public let method: ResourceTargetHTTPMethod = .get
  public let url: String

  public init(categoryId: Int) {
    self.url = "/category/\(categoryId)"
  }
}
