//
//  WorkspaceManager+CKSelector.swift
//  FableSDKViewPresenters
//
//  Created by Andrew Aquino on 12/27/19.
//

import FableSDKEnums
import FableSDKModelObjects
import UIKit


extension WorkspaceManager: CKSelectorWriteOnly {
  public func setFocus(_ focusKind: CKSelector.FocusKind) {
    modelManager.setFocus(focusKind)
  }

  @discardableResult
  public func maybeSetFocus(_ focusKind: CKSelector.FocusKind) -> Bool {
    modelManager.maybeSetFocus(focusKind)
  }

  public func unsetFocus() {
    modelManager.unsetFocus()
  }

  public func setFirstResponder(_ responder: UIResponder?) {
    modelManager.setFirstResponder(responder)
  }

  public func setSelected(_ selectionKind: CKSelector.SelectionKind) {
    modelManager.setSelected(selectionKind)
    switch selectionKind {
//    case let .message(messageId):
    case .message:
      break
//      if let character = modelManager.fetchCharacter(messageId: messageId) {
//        modelManager.setSelected(.character(character.characterId))
//      } else {
//        modelManager.setDeselected(.character)
//      }
    case .choice:
      // select choice + associated message
//      choiceModel.selectChoiceId(choiceId: choiceId)
//      // get the updated set of selected message groups to show
//      let selectedMessageGroupIds = choiceModel.recursiveSelectedMessageGroupIds(model: model)
//      // set selected message groups
//      selector.setSelected(.messageGroups(selectedMessageGroupIds))
      break
    default:
      break
    }
  }

  public func setDeselected(_ deselectionKind: CKSelector.DeselectionKind) {
    modelManager.setDeselected(deselectionKind)
    switch deselectionKind {
    case .message:
//      modelManager.setDeselected(.character)
      break
    case .choice:
//      choiceModel.deselectChoiceId(choiceId: choiceId)
//      // get the updated set of selected message groups to show
//      let selectedMessageGroupIds = choiceModel.recursiveSelectedMessageGroupIds(model: model)
//      // set selected message groups
//      selector.setSelected(.messageGroups(selectedMessageGroupIds))
      break
    default:
      break
    }
  }
}
