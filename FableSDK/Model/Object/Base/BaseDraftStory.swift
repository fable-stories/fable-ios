//
//  BaseStoryDraft.swift
//  FableSDKModelObjects
//
//  Created by Andrew Aquino on 7/3/20.
//

import AppFoundation
import FableSDKEnums
import Foundation

public protocol BaseStoryDraft: ModelObject, WireObject {
  var storyId: Int { get }
  var userId: Int { get }
  var currentChapterId: Int { get }
}
