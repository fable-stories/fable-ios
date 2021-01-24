//
//  CreateCategory.swift
//  FableSDKResourceTargets
//
//  Created by Enrique Florencio on 7/2/20.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct CreateCategory: ResourceTargetProtocol {
  public typealias RequestBodyType = WireCreateCategoryRequestBody
  public typealias ResponseBodyType = WireKategory

  public let method: ResourceTargetHTTPMethod = .post
  public let url: String = "/category"

  public init() {}
}
