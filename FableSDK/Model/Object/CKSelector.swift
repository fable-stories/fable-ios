//
//  CKSelector.swift
//  Fable
//
//  Created by Andrew Aquino on 11/29/19.
//

import ReactiveSwift
import UIKit

public protocol CKSelectorReadOnly {
  var selectedChapterId: Int? { get }
  var selectedMessageGroupId: Int? { get }
  var selectedMessageGroupIds: [Int] { get }
  var selectedCharacterId: Int? { get }
  var selectedMessageId: Int? { get }
  var selectedModifierId: Int? { get }
  var firstResponder: UIResponder? { get }
  var focusKind: CKSelector.FocusKind { get }
  var selectedChoiceIds: Set<Int> { get }

  var selectedChoiceId: Int? { get }
}

public protocol CKSelectorWriteOnly {
  mutating func setFirstResponder(_ responder: UIResponder?)
  mutating func setFocus(_ focusKind: CKSelector.FocusKind)
  mutating func unsetFocus()
  mutating func maybeSetFocus(_ focusKind: CKSelector.FocusKind) -> Bool
  mutating func setSelected(_ selectionKind: CKSelector.SelectionKind)
  mutating func setDeselected(_ deselectionKind: CKSelector.DeselectionKind)
}

public struct CKSelector: CKSelectorReadOnly, CKSelectorWriteOnly {
  public enum FocusKind {
    case message
    case character
    case none
  }

  public enum SelectionKind {
    case chapterId(Int)
    case messageGroup(Int)
    case messageGroups([Int])
    case message(Int)
    case character(Int)
    case modifier(Int)
    case choice(choiceId: Int)
    case none
  }

  public enum DeselectionKind {
    case message
    case character
    case modifier
    case messageGroup
    case messageGroups(Set<Int>)
    case choice(choiceId: Int)
    case none
  }

  public var selectedChapterId: Int?
  public var selectedMessageGroupId: Int?
  public var selectedMessageGroupIds: [Int] = []
  public var selectedCharacterId: Int?
  public var selectedMessageId: Int?
  public var selectedModifierId: Int?
  public var firstResponder: UIResponder?
  public var focusKind: CKSelector.FocusKind = .none

  public var selectedChoiceId: Int?

  // MARK: - Choice Path

  public var selectedChoiceIds: Set<Int> = []

  public init() {}

  public mutating func setFirstResponder(_ responder: UIResponder?) {
    firstResponder = responder
  }

  public mutating func setFocus(_ focusKind: CKSelector.FocusKind) {
    self.focusKind = focusKind
  }

  public mutating func maybeSetFocus(_ focusKind: CKSelector.FocusKind) -> Bool {
    if self.focusKind == .none {
      self.focusKind = focusKind
      return true
    }
    return false
  }

  public mutating func unsetFocus() {
    focusKind = .none
  }

  public mutating func setSelected(_ selectionKind: CKSelector.SelectionKind) {
    switch selectionKind {
    case let .chapterId(chapterId):
      selectedChapterId = chapterId
    case let .message(messageId):
      selectedMessageId = messageId
    case let .character(characterId):
      selectedCharacterId = characterId
    case let .modifier(modifierId):
      selectedModifierId = modifierId
    case let .messageGroup(messageGroupId):
      selectedMessageGroupId = messageGroupId
    case let .messageGroups(messageGroupIds):
      selectedMessageGroupIds = messageGroupIds
    case let .choice(choiceId):
      selectedChoiceId = choiceId
      selectedChoiceIds.insert(choiceId)
    case .none:
      selectedMessageId = nil
      selectedCharacterId = nil
      selectedModifierId = nil
    }
  }

  public mutating func setDeselected(_ deselectionKind: CKSelector.DeselectionKind) {
    switch deselectionKind {
    case .message:
      selectedMessageId = nil
    case .character:
      selectedCharacterId = nil
    case .modifier:
      selectedModifierId = nil
    case .messageGroup:
      selectedMessageGroupId = nil
    case let .messageGroups(messageGroupIds):
      selectedMessageGroupIds = selectedMessageGroupIds.filter { !messageGroupIds.contains($0) }
    case let .choice(choiceId):
      selectedChoiceId = nil
      selectedChoiceIds.remove(choiceId)
    case .none:
      break
    }
  }
}
