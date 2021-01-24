//
//  MutableStoryDraftModel.swift
//  FableSDKModelPresenters
//
//  Created by Andrew Aquino on 12/13/20.
//

import Foundation
import AppFoundation
import FableSDKModelObjects
import FableSDKEnums

internal class MutableStoryDraftModel: StoryDraftModel {
  private var story: MutableStory
  public var currentChapter: Chapter
  private var messages: [MutableMessage] = []
  private var characters: [Character] = []
  public var colorHexString: [String]
  
  private var characterById: [Int: MutableCharacter] = [:]
  private var messageById: [Int: MutableMessage] = [:]
  
  public func fetchStory() -> Story {
    story
  }
  
  public func updateStory(_ closure: @escaping (MutableStory) -> ()) {
    closure(self.story)
  }

  public func appendMessage(message: Message) {
    let message = MutableMessage(message: message)
    self.messages.append(message)
    self.messageById[message.messageId] = message
  }
  
  public func removeMessage(messageId: Int) {
    self.messages.removeFirst { $0.messageId == messageId }
    self.messageById[messageId] = nil
  }
  
  public func fetchMessage(messageId: Int) -> Message? {
    let message = self.messageById[messageId]
    message?.character = message?.characterId.flatMap(self.fetchCharacter(characterId:))
    return message
  }
  
  public func setCharacter(messageId: Int, characterId: Int?) {
    self.messageById[messageId]?.characterId = characterId
  }
  
  public func setMessages(_ messages: [Message]) {
    let messages = messages.map(MutableMessage.init(message:))
    self.messages = messages
    self.messageById = messages.indexed(by: \.messageId)
  }
  
  func fetchMessages() -> [Message] {
    self.messages.map { message in
      message.character = message.characterId.flatMap(self.fetchCharacter(characterId:))
      return message
    }
  }
  
  public func appendCharacter(character: Character) {
    let character = MutableCharacter(character: character)
    self.characters.append(character)
    self.characterById[character.characterId] = character
  }
  
  public func removeCharacter(characterId: Int) {
    self.characters.removeFirst { $0.characterId == characterId }
    self.characterById[characterId] = nil
  }
  
  public func fetchCharacter(characterId: Int) -> Character? {
    self.characterById[characterId]
  }
  
  public func updateCharacter(
    characterId: Int,
    name: String?,
    colorHexString: String?,
    messageAlignment: MessageAlignment?
  ) {
    let character = self.characterById[characterId]
    if let name = name { character?.name = name }
    if let colorHexString = colorHexString { character?.colorHexString = colorHexString }
    if let messageAlignment = messageAlignment { character?.messageAlignment = messageAlignment }
  }
  
  public func setCharacters(_ characters: [Character]) {
    let characters = characters.map(MutableCharacter.init(character:))
    self.characters = characters
    self.characterById = characters.indexed(by: \.characterId)
  }
  
  func fetchCharacters() -> [Character] {
    self.characters
  }
  
  public init(story: Story, currentChapter: Chapter, messages: [Message], characters: [Character], colorHexString: [String]) {
    self.story = MutableStory(story: story)
    self.currentChapter = currentChapter
    self.colorHexString = colorHexString
    self.setMessages(messages)
    self.setCharacters(characters)
  }
}
