//
//  StoryReaderScreen.swift
//  FableSDKModelObjects
//
//  Created by Andrew Aquino on 3/22/21.
//

import Foundation

public struct StoryReaderScreen {
  public init(story: Story, chapters: [Int : Chapter], messages: [Int : Message], characters: [Int : Character]) {
    self.story = story
    self.chapters = chapters
    self.messages = messages
    self.characters = characters
  }
  public let story: Story
  public let chapters: [Int: Chapter]
  public let messages: [Int: Message]
  public let characters: [Int: Character]
  
  public var selectedChapterId: Int {
    /// TOOD: clean this up
    self.chapters.values.first?.chapterId ?? -1
  }
}
