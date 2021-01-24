//
//  AttachImageToUser.swift
//  Fable
//
//  Created by Andrew Aquino on 8/24/19.
//

import FableSDKWireObjects
import Foundation
import NetworkFoundation
import UIKit

public struct AttachImageToUser: ResourceTargetProtocol {
  public typealias RequestBodyType = AttachImageToUserRequestBody
  public typealias ResponseBodyType = WireUser

  public let method: ResourceTargetHTTPMethod = .post
  public let url: String

  public func multipartFormdata() -> (MultiPartFormDataProtocol) -> Void {
    { mffd in
      guard let data = self.image.pngData() else { return }
      mffd.append(data, withName: "media", fileName: self.mediaKeyPath + ".png", mimeType: "png")
    }
  }

  private let image: UIImage
  private let mediaKeyPath: String

  public init(image: UIImage, mediaKeyPath: String) {
    self.url = "/user/media"
    self.image = image
    self.mediaKeyPath = mediaKeyPath
  }
}

public struct AttachImageToUserRequestBody: Codable {
  private let mediaKeyPath: String

  public init(mediaKeyPath: String) {
    self.mediaKeyPath = mediaKeyPath
  }
}
