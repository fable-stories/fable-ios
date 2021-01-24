//
//  BaseMessageGroup.swift
//  FableSDKModelObjects
//
//  Created by Andrew Aquino on 1/9/20.
//

import AppFoundation
import Foundation

public protocol BaseMessageGroup: ModelObject, WireObject {
  var messageGroupId: Int { get }
  var storyId: Int { get }
  var chapterId: Int { get }
  var userId: Int { get }

  // sourcery: unwrap=""""
  var messageGroupTitle: String? { get }
  var index: Int? { get }

  var previousMessageGroupId: Int? { get }
  var nextMessageGroupId: Int? { get }

  var sourceMessageId: Int? { get }

  // sourcery: date
  var createdAt: Date { get }
}
