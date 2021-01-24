//
//  Message+Extension.swift
//  FableSDKModelObjects
//
//  Created by Andrew Aquino on 1/9/20.
//

import Foundation
import AppFoundation

public extension Array where Element == Message {
  func sorted(dataStore: DataStore) -> [Message] {
    let log = Logger()
    log.enqueue("-- ALL --", logLevel: .debug)
    for message in dataStore.fetchMessages() {
      log.enqueue("messageId: \(message.messageId)", logLevel: .debug)
      log.enqueue("nextMessageId: \(message.nextMessageId ?? -1)", logLevel: .debug)
      log.enqueue("text: \(message.text)", logLevel: .debug)
      log.enqueue("----", logLevel: .debug)
    }
    var messages: [Message] = []
    var indexedMessages = dataStore.fetchMessages().indexed(by: \.messageId)
    var seen: Set<Int> = []
    
    log.enqueue("-- SORT --", logLevel: .debug)
    loop: while
      indexedMessages.isNotEmpty,
      let message = indexedMessages.values.first(where: { !seen.contains($0.messageId) })
    {
      log.enqueue("----", logLevel: .debug)
      if messages.isEmpty {
        messages.append(message)
        indexedMessages[message.messageId] = nil
        seen.removeAll()
        log.enqueue("messages: \(messages.map(\.messageId))", logLevel: .debug)
        log.enqueue("indexedMessages: \(indexedMessages.keys)", logLevel: .debug)
        continue loop
      }
      if
        let nextMessageId = message.nextMessageId,
        nextMessageId == messages.first?.messageId
      {
        messages.insert(message, at: 0)
        indexedMessages[message.messageId] = nil
        seen.removeAll()
        log.enqueue("messages: \(messages.map(\.messageId))", logLevel: .debug)
        log.enqueue("indexedMessages: \(indexedMessages.keys)", logLevel: .debug)
        continue loop
      } else if
        let nextMessageId = messages.last?.nextMessageId,
        nextMessageId == message.messageId
      {
        messages.append(message)
        indexedMessages[message.messageId] = nil
        seen.removeAll()
        log.enqueue("messages: \(messages.map(\.messageId))", logLevel: .debug)
        log.enqueue("indexedMessages: \(indexedMessages.keys)", logLevel: .debug)
        continue loop
      }
      seen.insert(message.messageId)
      log.enqueue("seen: \(seen)", logLevel: .debug)
    }
    // add in messages that are out of the link
    for message in seen.compactMap({ dataStore.fetchMessage(messageId: $0) }) {
      messages.append(message)
    }
    log.enqueue("-- SORTED --", logLevel: .debug)
    for message in messages {
      log.enqueue("messageId: \(message.messageId)", logLevel: .debug)
      log.enqueue("nextMessageId: \(message.nextMessageId ?? -1)", logLevel: .debug)
      log.enqueue("text: \(message.text)", logLevel: .debug)
      log.enqueue("----", logLevel: .debug)
    }
    log.flush()
    return messages
  }
}
