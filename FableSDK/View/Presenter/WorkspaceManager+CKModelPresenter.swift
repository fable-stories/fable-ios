//
//  WorkspaceManager+CKModelPresenter.swift
//  FableSDKViewPresenters
//
//  Created by Andrew Aquino on 12/27/19.
//

import FableSDKModelObjects
import FableSDKModelPresenters
import UIKit


extension WorkspaceManager: CKModelPresenterReadOnly {
  public var categories: [Kategory] {
    modelManager.fetchCategories()
  }
  
  public var messages: [Message] {
    modelManager.fetchMessages()
      .sorted(by: { lhs, rhs in lhs.displayIndex < rhs.displayIndex })
  }

  public var characters: [Character] {
    modelManager.fetchCharacters()
      .sorted(by: { $0.createdAt < $1.createdAt })
  }

  public var firstResponder: UIResponder? {
    modelManager.firstResponder
  }

  public var focusKind: CKSelector.FocusKind {
    modelManager.focusKind
  }

  public var selectedChapter: Chapter? {
    modelManager.selectedChapterId.flatMap(modelManager.fetchChapter)
  }

  public var selectedMessageGroups: [MessageGroup] {
    modelManager.fetchMessageGroups(messageGroupIds: modelManager.selectedMessageGroupIds)
  }

  public var selectedMessage: Message? {
    modelManager.selectedMessageId.flatMap(modelManager.fetchMessage)
  }

  public var selectedCharacter: Character? {
    modelManager.selectedCharacterId.flatMap(modelManager.fetchCharacter(characterId:))
  }

  public var selectedChoices: [Choice] {
    return []
  }

  public var colorHexStrings: [String] {
    modelManager.fetchColorHexStrings()
  }
}
