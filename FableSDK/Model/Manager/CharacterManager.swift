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
    return self.networkManager.request(GetCharactersByStoryId(storyId: storyId))
      .map { [weak self] wires in
        if let items = wires?.items.compactMap(MutableCharacter.init(wire:)) {
          for item in items {
            self?.characterById[item.characterId] = item
          }
          return items
        }
        return []
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
      CreateCharacter(),
      parameters: CreateCharacterRequestBody(
        storyId: storyId,
        userId: userId,
        name: name,
        colorHexString: colorHexString,
        messageAlignment: messageAlignment
      )
    )
    .mapException()
    .map { [weak self] wire in
      if let character = wire.flatMap(MutableCharacter.init(wire:)) {
        self?.characterById[character.characterId] = character
        return character
      }
      return nil
    }
    .eraseToAnyPublisher()
  }
  
  public func remove(characterId: Int) -> AnyPublisher<Void, Exception> {
    self.networkManager.request(DeleteDraftCharacter(characterId: characterId))
      .mapVoid().mapException()
  }
  
  public func update(characterId: Int, name: String?, colorHexString: String?, messageAlignment: String?) -> AnyPublisher<Void, Exception> {
    self.networkManager.request(
      UpdateDraftCharacter(characterId: characterId),
      parameters: UpdateCharacterRequestBody(
        name: name,
        colorHexString: colorHexString,
        messageAlignment: messageAlignment
      )
    ).mapVoid().mapException()
  }
}
