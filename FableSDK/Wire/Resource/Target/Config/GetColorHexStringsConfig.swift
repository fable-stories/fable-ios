//
//  GetColorHexStringsConfig.swift
//  Fable
//
//  Created by Andrew Aquino on 11/26/19.
//

import Foundation
import NetworkFoundation

public struct GetColorHexStringsConfig: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireCollection<String>

  public let method: ResourceTargetHTTPMethod = .get
  public let url: String

  public init() {
    self.url = "/creator/config/colorHexStrings"
  }
}
