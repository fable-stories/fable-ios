//
//  DeleteDraftChapter.swift
//  Fable
//
//  Created by Andrew Aquino on 11/25/19.
//

import Foundation
import NetworkFoundation

public struct DeleteDraftChapter: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = EmptyResponseBody

  public let method: ResourceTargetHTTPMethod = .delete
  public let url: String

  public init(storyId: Int, chapterId: Int) {
    self.url = "/creator/story/\(storyId)/chapter/\(chapterId)"
  }
}
