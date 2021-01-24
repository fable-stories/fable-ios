//
//  BaseUser.swift
//  FableSDKModelObjects
//
//  Created by Andrew Aquino on 1/6/20.
//

import AppFoundation
import Foundation

public protocol BaseUser: ModelObject, WireObject {
  var userId: Int { get }
  var firstName: String? { get }
  var lastName: String? { get }
  var userName: String? { get }
  var email: String? { get }
  var password: String? { get }
  var biography: String? { get }
  // sourcery: model=Asset
  var avatarAsset: BaseAsset? { get }
  // sourcery: date
  var createdAt: Date { get }
}
