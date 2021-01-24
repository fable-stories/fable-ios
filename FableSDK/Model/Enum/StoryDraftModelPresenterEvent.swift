//
//  StoryDraftModelPresenterEvent.swift
//  FableSDKEnums
//
//  Created by Andrew Aquino on 12/12/20.
//

import Foundation
import FableSDKFoundation
import AppFoundation

public enum StoryDraftModelPresenterEvent: EventContext, Equatable {
//  public var debugDescription: String {
//    switch self {
//    case .didDeleteStory(let storyId):
//      return "didDeleteStory \(storyId)"
//    case .didInsertCharacter(let characterId):
//      return "didInsertCharacter \(characterId)"
//    case .didInsertMessage(let messageId):
//      return "didInsertMessage \(messageId)"
//    case .didLoadInitialData:
//      return "didLoadInitialData \(characterId)"
//    case .didReceiveError(let error):
//      return "didReceiveError \(characterId)"
//    case .didRefreshCharacters:
//      return "didRefreshCharacters \(characterId)"
//    case .didRemoveCharacter(let characterId):
//      return "didRemoveCharacter \(characterId)"
//    case .didRemoveMessage(let messageId):
//      return "didRemoveMessage \(characterId)"
//    case .didRemoveCharacter(let characterId):
//      return "didRemoveCharacter \(characterId)"
//    case let .didSetCharacter(messageId, characterId):
//      return "didSetCharacter \(characterId)"
//    case .didSetEditMode(let editMode):
//      return "didSetEditMode \(characterId)"
//    case .didUpdateCharacter(let characterId):
//      return "didUpdateCharacter \(characterId)"
//    case .didUpdateStory(let storyId):
//    }
//  }
  
  case didLoadInitialData
  case didRefreshCharacters
  case didSetEditMode(editMode: StoryDraftEditMode)
  case didReceiveError(Exception)
  
  /// Story
  
  case didUpdateStory(storyId: Int)
  case didDeleteStory(storyId: Int)

  /// Messages
  
  case didInsertMessage(messageId: Int)
  case didRemoveMessage(messageId: Int)
  case didSetCharacter(messageId: Int, characterId: Int?)
  
  /// Characters
  case didInsertCharacter(characterId: Int)
  case didRemoveCharacter(characterId: Int)
  case didUpdateCharacter(characterId: Int)
}
