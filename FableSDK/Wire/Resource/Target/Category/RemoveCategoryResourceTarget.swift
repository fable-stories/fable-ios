//
//  RemoveCategoryResourceTarget.swift
//  FableSDKResourceTargets
//
//  Created by Enrique Florencio on 7/3/20.
//

import Foundation
import NetworkFoundation
import FableSDKWireObjects

public struct RemoveCategoryResourceTarget: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = EmptyResponseBody
  
  public let method: ResourceTargetHTTPMethod = .delete
  public let url: String
  
  public init(categoryId: Int) {
    self.url = "/category/\(categoryId)"
  }
}
