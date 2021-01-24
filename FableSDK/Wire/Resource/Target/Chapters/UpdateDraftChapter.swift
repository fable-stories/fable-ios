//
//  UpdateDraftChapter.swift
//  Fable
//
//  Created by Andrew Aquino on 11/25/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct UpdateDraftChapter: ResourceTargetProtocol {
  public typealias RequestBodyType = WireChapter
  public typealias ResponseBodyType = WireChapter

  public let method: ResourceTargetHTTPMethod = .put
  public let url: String

  public init(storyId: Int, chapterId: Int) {
    self.url = "/creator/story/\(storyId)/chapter/\(chapterId)"
  }
}
