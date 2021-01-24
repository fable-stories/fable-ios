//
//  BaseChoice.swift
//  FableSDKModelObjects
//
//  Created by Andrew Aquino on 1/9/20.
//

import AppFoundation
import Foundation

public protocol BaseChoice: ModelObject, WireObject {
  var choiceId: Int { get }
  var choiceGroupId: Int { get }
  // sourcery: unwrap=""""
  var choiceText: String? { get }
  // sourcery: date
  var createdAt: Date { get }
  var targetMessageGroupId: Int? { get }
}
