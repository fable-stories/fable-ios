//
//  MessageManager.swift
//  FableSDKModelManagers
//
//  Created by Andrew Aquino on 11/28/20.
//

import Foundation
import AppFoundation
import Combine
import FableSDKModelObjects
import FableSDKResourceTargets
import NetworkFoundation
import FableSDKWireObjects

public protocol MessageManager {
  func findCachedById(messageId: Int) -> Message?
  func listCachedByChapterId(chapterId: Int) -> [Message]
  
  func listByStoryId(storyId: Int) -> AnyPublisher<[Message], Exception>
  func listByChapterId(_ chapterId: Int) -> AnyPublisher<[Message], Exception>
  func insert(
    storyId: Int,
    chapterId: Int,
    text: String,
    previousMessageId: Int?,
    nextMessageId: Int?,
    characterId: Int?
  ) -> AnyPublisher<Message?, Exception>
  func remove(messageId: Int) -> AnyPublisher<Void, Exception>
  func update(messageId: Int, text: String?, displayIndex: Int?) -> AnyPublisher<Void, Exception>
  
  func setCharacter(messageId: Int, characterId: Int?) -> AnyPublisher<Void, Exception>
}

public class MessageManagerImpl: MessageManager {
  private let networkManager: NetworkManagerV2
  private let authManager: AuthManager
  
  private var messageById: [Int: Message] = [:]
  
  public func findCachedById(messageId: Int) -> Message? {
    messageById[messageId]
  }
  
  public func listCachedByChapterId(chapterId: Int) -> [Message] {
    messageById.values.filter { $0.chapterId == chapterId }
      .sorted(by: { $0.displayIndex < $1.displayIndex })
  }
  
  public init(networkManager: NetworkManagerV2, authManager: AuthManager) {
    self.networkManager = networkManager
    self.authManager = authManager
  }
  
  public func listByStoryId(storyId: Int) -> AnyPublisher<[Message], Exception> {
    self.networkManager.request(
      path: "/story/\(storyId)/message",
      method: .get
    ).map { [weak self] (wires: WireCollection<WireMessage>) in
      return wires.items.compactMap({ wire -> Message? in
        if let message = MutableMessage(wire: wire) {
          self?.messageById[message.messageId] = message
          return message
        }
        return nil
      })
    }
    .eraseToAnyPublisher()
  }
  
  public func listByChapterId(_ chapterId: Int) -> AnyPublisher<[Message], Exception> {
    self.networkManager.request(
      path: "/chapter/\(chapterId)/message",
      method: .get
    ).map { [weak self] (wires: WireCollection<WireMessage>) in
      return wires.items.compactMap({ wire -> Message? in
        if let message = MutableMessage(wire: wire) {
          self?.messageById[message.messageId] = message
          return message
        }
        return nil
      })
    }
    .eraseToAnyPublisher()
  }
  
  public func insert(
    storyId: Int,
    chapterId: Int,
    text: String,
    previousMessageId: Int?,
    nextMessageId: Int?,
    characterId: Int?
  ) -> AnyPublisher<Message?, Exception> {
    guard let userId = authManager.authenticatedUserId else { return .singleValue(nil) }
    return self.networkManager.request(
      path: "/message",
      method: .post,
      parameters: CreateMessageRequestBody(
        userId: userId,
        storyId: storyId,
        chapterId: chapterId,
        text: text,
        characterId: characterId,
        previousMessageId: previousMessageId,
        nextMessageId: nextMessageId,
        active: true
      )
    )
    .mapException()
    .map { [weak self] (wire: WireMessage) in
      if let message = MutableMessage(wire: wire) {
        self?.messageById[message.messageId] = message
        return message
      }
      return nil
    }
    .eraseToAnyPublisher()
  }
  
  public func remove(messageId: Int) -> AnyPublisher<Void, Exception> {
    self.networkManager.request(
      path: "/message/\(messageId)",
      method: .delete,
      expect: EmptyResponseBody.self
    )
    .mapVoid()
    .eraseToAnyPublisher()
  }
  
  public func update(messageId: Int, text: String?, displayIndex: Int?) -> AnyPublisher<Void, Exception> {
    self.networkManager.request(
      path: "/message/\(messageId)",
      method: .put,
      parameters: UpdateMessage.Request(
        text: text,
        displayIndex: displayIndex,
        nextMessageId: nil,
        active: nil
      ),
      expect: EmptyResponseBody.self
    ).mapVoid().eraseToAnyPublisher()
  }
  
  public func setCharacter(messageId: Int, characterId: Int?) -> AnyPublisher<Void, Exception> {
    self.networkManager.request(
      path: "/message/\(messageId)/character",
      method: .put,
      parameters: AttachCharacterToMessage.RequestBody(characterId: characterId),
      expect: WireModifier.self
    ).mapVoid()
  }
}
