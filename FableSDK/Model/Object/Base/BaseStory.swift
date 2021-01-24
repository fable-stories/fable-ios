//
//  BaseStory.swift
//  FableSDKModelObjects
//
//  Created by Andrew Aquino on 1/9/20.
//

import AppFoundation
import FableSDKEnums
import Foundation

public protocol BaseStory: ModelObject {
  var storyId: Int { get }
  var userId: Int { get }
  var selectedChapterId: Int? { get }
  var categoryId: Int? { get }
  var squareImageUrl: URL? { get }
  var landscapeImageUrl: URL? { get }
  // sourcery: unwrap=""""
  var title: String? { get }
  // sourcery: unwrap=""""
  var synopsis: String? { get }
  // sourcery: unwrap=[]
  var chapterIds: Set<Int>? { get }
  // sourcery: wire=published
  var isPublished: Bool { get }
  // sourcery: date
  var createdAt: Date { get }
  // sourcery: date
  var updatedAt: Date { get }
  // sourcery: date
  var deletedAt: Date? { get }
}
