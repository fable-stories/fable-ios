//
//  BaseChapter.swift
//  FableSDKModelObjects
//
//  Created by Andrew Aquino on 1/9/20.
//

import AppFoundation
import Foundation

public protocol BaseChapter:
  ModelObject, WireObject {
  var chapterId: Int { get }
  var storyId: Int { get }
  // sourcery: unwrap=""""
  var title: String? { get }
  var index: Int? { get }
  // sourcery: unwrap=[]
  var messageGroupIds: Set<Int>? { get }
  // sourcery: unwrap=[]
  var selectedMessageGroupIds: Set<Int>? { get }
  var previousChapterId: Int? { get }
  var nextChapterId: Int? { get }
  // sourcery: date
  var createdAt: Date { get }
}
