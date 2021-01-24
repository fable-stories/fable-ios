//
//  GetDraftCharactersFromUserResourceTarget.swift
//  FableSDKResourceTargets
//
//  Created by Enrique Florencio on 7/22/20.
//

import Foundation
import NetworkFoundation
import FableSDKWireObjects

public struct GetDraftCharactersFromUserResourceTarget: ResourceTargetProtocol {
  public typealias RequestBodyType = EmptyRequestBody
  public typealias ResponseBodyType = WireCollection<WireCharacter>
  
  public let method: ResourceTargetHTTPMethod = .get
  public let url: String
  
  public init(userId: Int) {
    self.url = "/user/\(userId)/character"
  }
}
