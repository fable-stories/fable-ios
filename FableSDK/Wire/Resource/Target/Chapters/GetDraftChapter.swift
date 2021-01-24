//
//  GetDraftChapter.swift
//  Fable
//
//  Created by Andrew Aquino on 11/25/19.
//

import AppFoundation
import FableSDKWireObjects
import Foundation
import NetworkFoundation

public struct GetDraftChapter: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireChapter

  public let method: ResourceTargetHTTPMethod = .get
  public let url: String

  public init(chapterId: Int) {
    self.url = "/chapter/\(chapterId)"
  }
}
