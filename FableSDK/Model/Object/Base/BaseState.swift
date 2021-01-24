//
//  BaseState.swift
//  FableSDKModelObjects
//
//  Created by Andrew Aquino on 1/11/20.
//

import AppFoundation
import Foundation

public protocol BaseState: ModelObject {
  var appSessionId: String { get }
  // sourcery: variable, model=User
  var currentUser: BaseUser? { get }
  // sourcery: variable, model=Config
  var config: BaseConfig? { get }
}
