//
//  RemoveCategory.swift
//  FableSDKResourceTargets
//
//  Created by Enrique Florencio on 7/3/20.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct RemoveCategory: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = EmptyResponseBody

  public let method: ResourceTargetHTTPMethod = .delete
  public let url: String

  public init(categoryId: Int) {
    self.url = "/category/\(categoryId)"
  }
}
