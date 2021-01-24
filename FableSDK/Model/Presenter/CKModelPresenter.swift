//
//  CKModelPresenter.swift
//  Fable
//
//  Created by Andrew Aquino on 12/14/19.
//

import AppFoundation
import FableSDKResolver
import FableSDKModelManagers
import FableSDKModelObjects
import ReactiveSwift
import UIKit

public protocol CKModelPresenterReadOnly {
  var story: Story { get }
  var categories: [FableSDKModelObjects.Kategory] { get }
  var messages: [Message] { get }
  var characters: [Character] { get }
  var firstResponder: UIResponder? { get }
  var focusKind: CKSelector.FocusKind { get }
  var selectedChapter: Chapter? { get }
  var selectedMessageGroups: [MessageGroup] { get }
  var selectedMessage: Message? { get }
  var selectedCharacter: Character? { get }
  var selectedChoices: [Choice] { get }
  var colorHexStrings: [String] { get }
}

public protocol CKModelPresenterDelegate: AnyObject {
  func modelPresenter(sortMessageGroupsById: Set<String>) -> [MessageGroup]
}


public class CKModelPresenter: CKModelPresenterReadOnly {
  internal let globalQueue: DispatchQueue

  // MARK: - Delegate

  public weak var delegate: CKModelPresenterDelegate?

  // MARK: - Presenters

  private let choiceModel: ChoiceModelReadOnly

  // MARK: - Models

  public var story: Story { model.story }

  public var categories: [FableSDKModelObjects.Kategory] {
    model.fetchCategories()
  }

  public var messages: [Message] {
    model.fetchMessages()
      .compactMap { $0 as? MutableMessage }
      .sorted(by: { $0.displayIndex < $1.displayIndex })
      .map { $0.hydrate(model: model) }
  }

  public var lastMessageGroup: MessageGroup? {
    selectedMessageGroups.last
  }

  public var characters: [Character] {
    model.fetchCharacters()
  }

  // MARK: - Dependencies

  private let model: CKModelReadOnly
  private let sortedModel: SortedModel
  private let selector: CKSelectorReadOnly
  private let stateManager: StateManager

  public init(
    stateManager: StateManager,
    model: CKModelReadOnly,
    globalQueue: DispatchQueue,
    sortedModel: SortedModel,
    choiceModel: ChoiceModelReadOnly,
    selector: CKSelectorReadOnly
  ) {
    self.stateManager = stateManager
    self.model = model
    self.globalQueue = globalQueue
    self.sortedModel = sortedModel
    self.selector = selector
    self.choiceModel = choiceModel
  }
}

// MARK: - Selected Models


extension CKModelPresenter {
  public var firstResponder: UIResponder? {
    selector.firstResponder
  }

  public var focusKind: CKSelector.FocusKind {
    selector.focusKind
  }

  public var selectedChapter: Chapter? {
    selector.selectedChapterId.flatMap { model.fetchChapter(chapterId: $0) }
  }

  public var selectedMessageGroups: [MessageGroup] {
    model.fetchMessageGroups(messageGroupIds: selector.selectedMessageGroupIds)
  }

  public var selectedMessage: Message? {
    selector.selectedMessageId.flatMap { model.fetchMessage(messageId: $0) }
  }

  public var selectedCharacter: Character? {
    selector.selectedCharacterId.flatMap { model.fetchCharacter(characterId: $0) }
  }

  public var selectedChoices: [Choice] {
    selector.selectedChoiceIds.compactMap { model.fetchChoice(choiceId: $0) }
  }

  public var colorHexStrings: [String] {
    stateManager.state().config?.colorHexStrings ?? []
  }
}
