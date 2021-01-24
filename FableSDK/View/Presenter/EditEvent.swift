//
//  EditEvent.swift
//  FableSDKViewPresenters
//
//  Created by Andrew Aquino on 9/13/20.
//

import Foundation
import AppFoundation

public enum EditEvent: EditEventProtocol {
  case normal
  
  case updateMessage(UpdateMessageEvent)
  case selectMessage(SelectMessageEvent)
  case appendMessage(AppendMessageEvent)
  
  case messageInputCommand(MessageInputCommandEvent)
  
  case selectCharacter(SelectCharacterEvent)
  case characterControlBarCommand(CCBarCommandEvent)

  public var sessionId: String {
    switch self {
    case .normal: return normalEditSessionId
    case let .appendMessage(event): return event.sessionId
    case let .messageInputCommand(event): return event.sessionId
    case let .selectMessage(event): return event.sessionId
    case let .updateMessage(event): return event.sessionId
    case let .selectCharacter(event): return event.sessionId
    case let .characterControlBarCommand(event): return event.sessionId
    }
  }
}

public extension EditEvent {
  struct NormalEditEvent: EditEventProtocol {
    public let sessionId: String
    public init(sessionId: String = normalEditSessionId) {
      self.sessionId = sessionId
    }
  }

  struct MessageInputCommandEvent: EditEventProtocol {
    public enum Command {
      case setText(String)
      case becomeFirstResponder
      case resignFirstResponder
    }
    public let sessionId: String
    public let command: Command
    public init(sessionId: String = normalEditSessionId, command: Command) {
      self.sessionId = sessionId
      self.command = command
    }
  }
  
  struct AppendMessageEvent: EditEventProtocol {
    public let sessionId: String
    public let previousMessageId: Int?
    public let selectedMessageId: Int?
    public let nextMessageId: Int?
    public let text: String
    public let characterId: Int?
    public let scrollToLastMessage: Bool
    public init(
      sessionId: String = normalEditSessionId,
      previousMessageId: Int?,
      selectedMessageId: Int?,
      nextMessageId: Int?,
      text: String,
      characterId: Int?,
      scrollToLastMessage: Bool
    ) {
      self.sessionId = sessionId
      self.previousMessageId = previousMessageId
      self.selectedMessageId = selectedMessageId
      self.nextMessageId = nextMessageId
      self.text = text
      self.characterId = characterId
      self.scrollToLastMessage = scrollToLastMessage
    }
  }
  
  struct UpdateMessageEvent: EditEventProtocol {
    public let sessionId: String
    public let messageId: Int
    public let text: String?
    public let displayIndex: Int?
    public let active: Bool?
    public init(
      sessionId: String = normalEditSessionId,
      messageId: Int,
      text: String? = nil,
      displayIndex: Int? = nil,
      active: Bool? = nil
    ) {
      self.sessionId = sessionId
      self.messageId = messageId
      self.text = text
      self.displayIndex = displayIndex
      self.active = active
    }
  }
  
  struct SelectMessageEvent: EditEventProtocol {
    public let sessionId: String
    public let messageId: Int?
    public init(sessionId: String = normalEditSessionId, messageId: Int?) {
      self.sessionId = sessionId
      self.messageId = messageId
    }
  }
  
  struct SelectCharacterEvent: EditEventProtocol {
    public let sessionId: String
    public let characterId: Int?
    public init(sessionId: String = normalEditSessionId, characterId: Int?) {
      self.sessionId = sessionId
      self.characterId = characterId
    }
  }
  
  struct CCBarCommandEvent: EditEventProtocol {
    public enum Command {
      case selectCharacter(characterId: Int?)
    }
    public let sessionId: String
    public let command: Command
    public init(sessionId: String = normalEditSessionId, command: Command) {
      self.sessionId = sessionId
      self.command = command
    }
  }
}
