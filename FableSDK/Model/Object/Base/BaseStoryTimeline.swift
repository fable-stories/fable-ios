//
//  BaseStoryTimeline.swift
//  FableSDKModelObjects
//
//  Created by Andrew Aquino on 7/17/20.
//

import AppFoundation
import FableSDKEnums
import Foundation

public protocol BaseStoryTimeline: ModelObject, WireObject {
  var storyTimelineId: Int { get }
  var storyId: Int { get }
  var userId: Int { get }
  var currentChapterId: Int { get }
  // sourcery: date
  var createdAt: Date { get }
  // sourcery: date
  var updatedAt: Date { get }
}

