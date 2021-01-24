//
//  UpdateUser.swift
//  Fable
//
//  Created by Andrew Aquino on 12/23/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct UpdateUserRequestBody: Codable {
  public let userName: String?
  public let biography: String?
  public let avatarAssetId: Int?
  public init(
    userName: String? = nil,
    biography: String? = nil,
    avatarAssetId: Int? = nil
  ) {
    self.userName = userName
    self.biography = biography
    self.avatarAssetId = avatarAssetId
  }
}

public struct UpdateUser: ResourceTargetProtocol {
  public typealias RequestBodyType = UpdateUserRequestBody
  public typealias ResponseBodyType = EmptyResponseBody

  public let method: ResourceTargetHTTPMethod = .put
  public let url: String

  public init(userId: Int) {
    self.url = "/user/\(userId)"
  }
}
