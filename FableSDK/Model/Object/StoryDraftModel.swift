//
//  StoryDraftModel.swift
//  FableSDKModelObjects
//
//  Created by Andrew Aquino on 12/11/20.
//

import Foundation

public protocol StoryDraftModel {
  var currentChapter: Chapter { get }
  var colorHexString: [String] { get }
  
  func fetchStory() -> Story

  func fetchMessage(messageId: Int) -> Message?
  func fetchMessages() -> [Message]
  
  func fetchCharacter(characterId: Int) -> Character?
  func fetchCharacters() -> [Character]
}
