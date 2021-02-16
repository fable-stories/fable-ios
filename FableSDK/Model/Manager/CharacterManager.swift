//
//  CharacterManager.swift
//  FableSDKModelManagers
//
//  Created by Andrew Aquino on 11/28/20.
//

import Foundation
import AppFoundation
import Combine
import FableSDKModelObjects
import FableSDKResourceTargets
import FableSDKWireObjects
import NetworkFoundation

public protocol CharacterManager {
  func listCachedByStoryId(storyId: Int) -> [Character]
  func listByStoryId(_ storyId: Int) -> AnyPublisher<[Character], Exception>
  func insert(storyId: Int, name: String, colorHexString: String, messageAlignment: String) -> AnyPublisher<Character?, Exception>
  func remove(characterId: Int) -> AnyPublisher<Void, Exception>
  func update(characterId: Int, name: String?, colorHexString: String?, messageAlignment: String?) -> AnyPublisher<Void, Exception>
}

public class CharacterManagerImpl: CharacterManager {
  private let networkManager: NetworkManagerV2
  private let authManager: AuthManager
  
  private var characterById: [Int: Character] = [:]
  
  public init(
    networkManager: NetworkManagerV2,
    authManager: AuthManager
  ) {
    self.networkManager = networkManager
    self.authManager = authManager
  }
  
  public func listCachedByStoryId(storyId: Int) -> [Character] {
    characterById.values.filter { $0.storyId == storyId }
  }
  
  public func listByStoryId(_ storyId: Int) -> AnyPublisher<[Character], Exception> {
    return self.networkManager.request(
      path: "/story/\(storyId)/character",
      method: .get,
      expect: WireCollection<WireCharacter>.self
    ).map { [weak self] wires in
      let items = wires.items.compactMap(MutableCharacter.init(wire:))
      for item in items {
        self?.characterById[item.characterId] = item
      }
      return items
    }
    .eraseToAnyPublisher()
  }
  
  public func insert(
    storyId: Int,
    name: String,
    colorHexString: String,
    messageAlignment: String
  ) -> AnyPublisher<Character?, Exception> {
    guard let userId = self.authManager.authenticatedUserId else { return .singleValue(nil) }
    return self.networkManager.request(
      path: "/character",
      method: .post,
      parameters: CreateCharacterRequestBody(
        storyId: storyId,
        userId: userId,
        name: name,
        colorHexString: colorHexString,
        messageAlignment: messageAlignment
      ),
      expect: WireCharacter.self
    )
    .mapException()
    .map { [weak self] wire in
      if let character = MutableCharacter(wire: wire) {
        self?.characterById[character.characterId] = character
        return character
      }
      return nil
    }
    .eraseToAnyPublisher()
  }
  
  public func remove(characterId: Int) -> AnyPublisher<Void, Exception> {
    self.networkManager.request(
      path: "/character/\(characterId)",
      method: .delete,
      expect: EmptyResponseBody.self
    ).mapVoid().mapException()
  }
  
  public func update(characterId: Int, name: String?, colorHexString: String?, messageAlignment: String?) -> AnyPublisher<Void, Exception> {
    self.networkManager.request(
      path: "/character/\(characterId)",
      method: .put,
      parameters: UpdateCharacterRequestBody(
        name: name,
        colorHexString: colorHexString,
        messageAlignment: messageAlignment
      ),
      expect: EmptyResponseBody.self
    ).mapVoid().mapException()
  }
}
