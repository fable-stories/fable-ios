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
  
  case didLoadInitialData
  case didRefreshCharacters
  case didSetEditMode(editMode: StoryDraftEditMode)
  case didReceiveError(Exception)
  
  /// Story
  
  case didUpdateStory(storyId: Int)
  case didDeleteStory(storyId: Int)
  case didCreateStory(storyId: Int)

  /// Messages
  
  case didInsertMessage(messageId: Int)
  case didRemoveMessage(messageId: Int)
  case didSetCharacter(messageId: Int, characterId: Int?)
  
  /// Characters
  case didInsertCharacter(characterId: Int)
  case didRemoveCharacter(characterId: Int)
  case didUpdateCharacter(characterId: Int)
}
