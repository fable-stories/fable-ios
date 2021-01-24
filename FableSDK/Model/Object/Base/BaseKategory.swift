//
//  BaseCategory.swift
//  FableSDKModelObjects
//
//  Created by Andrew Aquino on 1/6/20.
//

import AppFoundation
import Foundation

public protocol BaseKategory:
  ModelObject, WireObject {
  var categoryId: Int { get }
  // sourcery: unwrap=""""
  var title: String? { get }
  // sourcery: unwrap=""""
  var subtitle: String? { get }
  // sourcery: unwrap=[], model=Story, collection
  var stories: [BaseStory]? { get }
}
