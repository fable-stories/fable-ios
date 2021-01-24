//
//  AttachImageToStory.swift
//  Fable
//
//  Created by Andrew Aquino on 8/23/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation
import UIKit

public struct AttachImageToStory: ResourceTargetProtocol {
  public typealias RequestBodyType = AttachImageToStoryRequestBody
  public typealias ResponseBodyType = WireStory

  public let method: ResourceTargetHTTPMethod = .post
  public let url: String

  public func multipartFormdata() -> (MultiPartFormDataProtocol) -> Void {
    { mffd in
      guard let data = self.image.pngData() else { return }
      mffd.append(data, withName: "media", fileName: self.filename + ".png", mimeType: "png")
    }
  }

  private let image: UIImage
  private let filename: String

  public init(storyId: Int, image: UIImage, filename: String) {
    self.url = "/story/\(storyId)/media"
    self.image = image
    self.filename = filename
  }
}

public struct AttachImageToStoryRequestBody: Codable {
  private let mediaKeyPath: String

  public init(mediaKeyPath: String) {
    self.mediaKeyPath = mediaKeyPath
  }
}
