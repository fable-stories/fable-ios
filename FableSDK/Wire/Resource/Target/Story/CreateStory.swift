//
//  CreateStory.swift
//  AppFoundation
//
//  Created by Giordany Orellana on 6/27/20.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct CreateStoryRequestBody: Codable {
  public let userId: Int
  public let title: String
  public let synopsis: String
    
  public init (userId: Int, title: String, synopsis: String) {
      self.userId = userId
      self.title = title
      self.synopsis = synopsis
  }
}

public struct CreateStory: ResourceTargetProtocol {
  public typealias RequestBodyType = CreateStoryRequestBody
  public typealias ResponseBodyType = WireStory

  public let method: ResourceTargetHTTPMethod = .post
  public let url: String = "/story"

  public init() {}
}
