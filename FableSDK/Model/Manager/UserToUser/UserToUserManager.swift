//
//  UserToUserManager.swift
//  FableSDKModelManagers
//
//  Created by Andrew Aquino on 2/17/21.
//

import Foundation
import Combine
import AppFoundation
import NetworkFoundation
import FableSDKModelObjects

public protocol UserToUserManager {
  func setUserBlocked(userId: Int, isBlocked: Bool) -> AnyPublisher<Void, Exception>
  func cacheUserToUser(userId: Int, userToUser: UserToUser)
  func fetchUserToUser(userId: Int) -> UserToUser?
}

public class UserToUserManagerImpl: UserToUserManager {
  
  private let networkManager: NetworkManagerV2
  private let eventManager: EventManager
  private let authManager: AuthManager
  
  private var userIdToUserToUser: [Int: UserToUser] = [:]
  
  public init(
    networkManager: NetworkManagerV2,
    eventManager: EventManager,
    authManager: AuthManager
  ) {
    self.networkManager = networkManager
    self.eventManager = eventManager
    self.authManager = authManager
  }
  
  public func cacheUserToUser(userId: Int, userToUser: UserToUser) {
    userIdToUserToUser[userId] = userToUser
  }
  
  public func fetchUserToUser(userId: Int) -> UserToUser? {
    userIdToUserToUser[userId]
  }

  public func setUserBlocked(userId: Int, isBlocked: Bool) -> AnyPublisher<Void, Exception> {
    return self.networkManager.request(
      path: "/user/to/user",
      method: .post,
      parameters: UserToUserRequestBody(toUserId: userId, blocked: isBlocked),
      expect: EmptyResponseBody.self
    )
    .mapVoid()
    .also { [weak self] in
      if var userToUser = self?.userIdToUserToUser[userId] as? MutableUserToUser {
        userToUser.isBlocked = isBlocked
        self?.userIdToUserToUser[userId] = userToUser
      }
    }
  }
}

private struct UserToUserRequestBody: Codable {
  public let toUserId: Int
  public let blocked: Bool
  public init(toUserId: Int, blocked: Bool) {
    self.toUserId = toUserId
    self.blocked = blocked
  }
}
