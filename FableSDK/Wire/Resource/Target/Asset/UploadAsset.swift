//
//  CreateCategoryResourceTarget.swift
//  FableSDKResourceTargets
//
//  Created by Enrique Florencio on 7/2/20.
//

import Foundation
import AppFoundation
import NetworkFoundation
import FableSDKWireObjects

public struct UploadAssetRequest: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireAsset
  
  public let method: ResourceTargetHTTPMethod = .post
  public let url: String
  
  private let file: Data
  private let fileName: String
  private let mimeType: String
  private let tags: [String]

  public init(userId: Int, file: Data, fileName: String, tags: [String] = []) {
    self.url = "/user/\(userId)/asset"
    self.file = file
    self.fileName = fileName
    self.mimeType = file.mimeType
    self.tags = tags
  }
  
  public func multipartFormdata() -> (MultiPartFormDataProtocol) -> Void {
    return { form in
      form.append(self.file, withName: "file", fileName: self.fileName, mimeType: self.mimeType)
      form.append("ios", withName: "objectSouce")
      if self.tags.isNotEmpty {
        form.append(self.tags.joined(separator: ","), withName: "tags")
      }
    }
  }
}
