//
//  Story+Wire.swift
//  FableSDKWireObjects
//
//  Created by Andrew Aquino on 3/22/21.
//

import Foundation

public struct WireStoryReaderScreen: Codable {
  public let story: WireStory
  public let chapters: [WireChapter]
  public let messages: [WireMessage]
  public let characters: [WireCharacter]
}

public struct WireStoryDetailScreen: Codable {
  public let story: WireStory
}
