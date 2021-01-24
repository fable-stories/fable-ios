//
//  BaseCharacter.swift
//  FableSDKModelObjects
//
//  Created by Andrew Aquino on 1/9/20.
//

import AppFoundation
import FableSDKEnums
import Foundation

public protocol BaseCharacter: ModelObject, WireObject {
  var characterId: Int { get }
  var userId: Int { get }
  var storyId: Int { get }

  // sourcery: unwrap=[]

  // sourcery: unwrap=""""
  var name: String? { get }
  var colorHexString: String? { get }
  // sourcery: enum=String, unwrap=.center
  var messageAlignment: MessageAlignment? { get }
  // sourcery: date
  var createdAt: Date { get }
}
