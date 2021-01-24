//
//  BaseChoiceGroup.swift
//  FableSDKModelObjects
//
//  Created by Andrew Aquino on 1/9/20.
//

import AppFoundation
import FableSDKEnums
import Foundation

public protocol BaseChoiceGroup: ModelObject, WireObject {
  var choiceGroupId: Int { get }
  var modifierId: Int { get }
  var modifierKind: ModifierKind { get }
  var userId: Int { get }
  var storyId: Int { get }
  var messageId: Int { get }
  var messageGroupId: Int { get }
  // sourcery: model=Choice, collection, unwrap=[], modelPrimaryKey=choiceId
  var choices: [BaseChoice]? { get }
  // sourcery: date
  var createdAt: Date { get }
}
