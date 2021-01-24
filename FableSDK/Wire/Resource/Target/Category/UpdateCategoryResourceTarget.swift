//
//  UpdateCategoryResourceTarget.swift
//  FableSDKResourceTargets
//
//  Created by Enrique Florencio on 7/9/20.
//

import Foundation
import NetworkFoundation
import FableSDKWireObjects

public struct UpdateCategoryResourceTarget: ResourceTargetProtocol {
  public typealias RequestBodyType = WireUpdateCategoryRequestBody
  public typealias ResponseBodyType = EmptyResponseBody
  
  public let method: ResourceTargetHTTPMethod = .put
  public let url: String
  
  public init(categoryId: Int) {
    self.url = "/category/\(categoryId)"
  }
}
