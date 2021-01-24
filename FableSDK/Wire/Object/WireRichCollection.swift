//
//  WireRichCollection.swift
//  FableSDKModelObjects
//
//  Created by Andrew Aquino on 12/25/19.
//

import AppFoundation
import Foundation

public struct WireRichCollection: Codable, InitializableWireObject {
  public let story: WireStory?
  public let chapter: WireChapter?
  public let chapters: [WireChapter]?
  public let messageGroups: [WireMessageGroup]?
  public let messages: [WireMessage]?
  public let characters: [WireCharacter]?
}
