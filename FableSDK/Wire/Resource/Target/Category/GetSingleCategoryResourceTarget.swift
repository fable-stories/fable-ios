//
//  GetSingleCategoryResourceTarget.swift
//  FableSDKResourceTargets
//
//  Created by Enrique Florencio on 7/10/20.
//

import Foundation
import NetworkFoundation
import FableSDKWireObjects

public struct GetSingleCategoryResourceTarget: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireKategory
  
  public let method: ResourceTargetHTTPMethod = .get
  public let url: String
  
  public init(categoryId: Int) {
    self.url = "/category/\(categoryId)"
  }
}
