//
//  GetUsers.swift
//  Fable
//
//  Created by Andrew Aquino on 8/13/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct GetUser: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireUser

  public let method: ResourceTargetHTTPMethod = .get
  public let url: String

  public init(userId: Int) {
    self.url = "/user/\(userId)"
  }
}

public struct GetUsers: ResourceTargetProtocol {
  public struct Request: Codable {
    public let userIds: [Int]?
    public init(userIds: Set<Int>?) {
      self.userIds = userIds.flatMap(Array.init)
    }
  }
  
  public typealias RequestBodyType = Request
  public typealias ResponseBodyType = WireCollection<WireUser>
  
  public let method: ResourceTargetHTTPMethod = .get
  public let url: String
  
  public init() {
    self.url = "/user"
  }
}

public struct GetUsersFollowedByUserId: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireCollection<WireUser>
  
  public let method: ResourceTargetHTTPMethod = .get
  public let url: String
  
  public init(userId: Int) {
    self.url = "/user/\(userId)/followed"
  }
}

public struct GetUsersFollowingUserId: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireCollection<WireUser>
  
  public let method: ResourceTargetHTTPMethod = .get
  public let url: String
  
  public init(userId: Int) {
    self.url = "/user/\(userId)/followers"
  }
}
