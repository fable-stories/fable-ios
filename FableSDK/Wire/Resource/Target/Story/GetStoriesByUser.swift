//
//  GetStoriesByUser.swift
//  Fable
//
//  Created by Andrew Aquino on 12/24/19.
//

import AppFoundation
import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct GetStoriesByUser: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireCollection<WireStory>

  public let method: ResourceTargetHTTPMethod = .get
  public let url: String

  public init(userId: Int) {
    self.url = "/user/\(userId)/story"
  }
}
