//
// Created by Andrew Aquino on 1/13/20.
//

import FableSDKModelObjects
import FableSDKResourceTargets
import Foundation
import Combine
import AppFoundation
import FableSDKFoundation
import FableSDKWireObjects
import NetworkFoundation

public enum UserManagerEvent: EventContext, Equatable {
  case didRefreshMyUser(count: Int)
  case didRefreshUser(userId: Int)
  case didSetFollowStatus(userId: Int, isFollowing: Bool)
}

public protocol UserManager {
  var currentUser: User? { get }
  
  func fetchUser(userId: Int) -> User?
  func fetchUsers(userIds: [Int]) -> [User]
  func cacheUser(user: User)
  func refreshUser(userId: Int) -> AnyPublisher<User?, Exception>
  func refreshUsers(userIds: Set<Int>) -> AnyPublisher<[User], Exception>
  func refreshUsers(followingUserId userId: Int) -> AnyPublisher<[User], Exception>
  func refreshUsers(followedByuserId userId: Int) -> AnyPublisher<[User], Exception>

  /// Me
  
  func refreshMyUser()
  func setFollowStatus(userId: Int, isFollowing: Bool) -> AnyPublisher<Void, Exception>
  func agreeToEULA() -> AnyPublisher<Void, Exception>
}

public class UserManagerImpl: UserManager {
  public var currentUser: User? { authManager.authenticatedUserId.flatMap(fetchUser(userId:)) }
  
  private var usersById: [Int: User] = [:]

  private let stateManager: StateManager
  private let networkManager: NetworkManagerV2
  private let environmentManager: EnvironmentManager
  private let authManager: AuthManager
  private let eventManager: EventManager
  private let userToUserManager: UserToUserManager

  private var myUserRefreshCount = 0

  public init(
    stateManager: StateManager,
    networkManager: NetworkManagerV2,
    environmentManager: EnvironmentManager,
    authManager: AuthManager,
    eventManager: EventManager,
    userToUserManager: UserToUserManager
  ) {
    self.stateManager = stateManager
    self.networkManager = networkManager
    self.environmentManager = environmentManager
    self.authManager = authManager
    self.eventManager = eventManager
    self.userToUserManager = userToUserManager

    refreshMyUser()

    // refresh the user each time the environment changes
    environmentManager.onUpdate.take(duringLifetimeOf: self).observeValues { [weak self] in
      self?.refreshMyUser()
    }
  }
  
  public func fetchUser(userId: Int) -> User? {
    usersById[userId]
  }
  
  public func fetchUsers(userIds: [Int]) -> [User] {
    userIds.compactMap { usersById[$0] }
  }
  
  public func cacheUser(user: User) {
    usersById[user.userId] = user
  }
  
  public func refreshUser(userId: Int) -> AnyPublisher<User?, Exception> {
    networkManager.request(
      path: "/user/\(userId)",
      method: .get,
      expect: WireUser?.self
    ).mapException().map { [weak self] wire in
      if let user = wire.flatMap(User.init(wire:)) {
        self?.userToUserManager.cacheUserToUser(userId: user.userId, userToUser: user.userToUser)
        self?.usersById[userId] = user
        self?.eventManager.sendEvent(UserManagerEvent.didRefreshUser(userId: userId))
        return user
      }
      return nil
    }.eraseToAnyPublisher()
  }
  
  public func refreshUsers(userIds: Set<Int>) -> AnyPublisher<[User], Exception> {
    self.networkManager.request(
      path: "/user",
      method: .get,
      parameters: GetUsers.Request(userIds: userIds),
      expect: WireCollection<WireUser>.self
    ).map { [weak self] wire in
      let users = wire.items.compactMap(User.init(wire:))
      for user in users {
        self?.cacheUser(user: user)
      }
      return users
    }.eraseToAnyPublisher()
  }
  
  public func refreshUsers(followedByuserId userId: Int) -> AnyPublisher<[User], Exception> {
    self.networkManager.request(
      path: "/user/\(userId)/followed",
      method: .get,
      expect: WireCollection<WireUser>.self
    ).map { [weak self] wire in
      let users = wire.items.compactMap(User.init(wire:))
      for user in users {
        self?.cacheUser(user: user)
      }
      return users
    }.eraseToAnyPublisher()
  }
  
  public func refreshUsers(followingUserId userId: Int) -> AnyPublisher<[User], Exception> {
    self.networkManager.request(
      path: "/user/\(userId)/followers",
      method: .get,
      expect: WireCollection<WireUser>.self
    ).map { [weak self] wire in
      let users = wire.items.compactMap(User.init(wire:))
      for user in users {
        self?.cacheUser(user: user)
      }
      return users
    }.eraseToAnyPublisher()
  }

  /// My User

  public func refreshMyUser() {
    guard let userId = authManager.authenticatedUserId else {
      stateManager.modifyState { state in
        state.currentUser = nil
      }
      return
    }
    networkManager.request(
      path: "/user/\(userId)",
      method: .get,
      expect: WireUser?.self
    ).sinkDisposed(receiveCompletion: nil, receiveValue: { [weak self] wire in
      guard let self = self else { return }
      guard let user = wire.flatMap({ User(wire: $0) }) else { return }
      self.cacheUser(user: user)
      self.stateManager.modifyState { state in
        state.currentUser = user
      }
      self.myUserRefreshCount += 1
      self.eventManager.sendEvent(UserManagerEvent.didRefreshMyUser(count: self.myUserRefreshCount))
    })
  }
  
  public func setFollowStatus(userId: Int, isFollowing: Bool) -> AnyPublisher<Void, Exception> {
    guard let selfUserId = authManager.authenticatedUserId, selfUserId != userId else { return .singleValue(()) }
    return networkManager.request(
      path: "/user/\(selfUserId)/to/user/\(userId)",
      method: .post,
      parameters: UpsertUserToUserResource.Request(isFollowing: isFollowing),
      expect: EmptyResponseBody.self
    ).mapException().mapVoid().also { [weak self] in
      if var user = self?.fetchUser(userId: userId) {
        user.userToUser = user.userToUser.copy({ $0["isFollowing"] = isFollowing })
        self?.cacheUser(user: user)
      }
      self?.eventManager.sendEvent(UserManagerEvent.didSetFollowStatus(userId: userId, isFollowing: isFollowing))
    }
  }
  
  public func agreeToEULA() -> AnyPublisher<Void, Exception> {
    guard let myUserId = authManager.authenticatedUserId else { return .singleValue(()) }
    return networkManager.request(
      path: "/user/\(myUserId)",
      method: .put,
      parameters: [
        "eula_agreed_at": Date.now
      ],
      expect: EmptyResponseBody.self
    )
    .mapException()
    .mapVoid()
    .also { [weak self] in
      if var user = self?.fetchUser(userId: myUserId) {
        user.eulaAgreedAt = .now
        self?.cacheUser(user: user)
      }
    }
  }
}
