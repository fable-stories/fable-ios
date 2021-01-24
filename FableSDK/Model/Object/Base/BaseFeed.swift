//
//  BaseFeed.swift
//  FableSDKModelObjects
//
//  Created by Andrew Aquino on 1/12/20.
//

import AppFoundation
import Foundation

public protocol BaseFeed: ModelObject {
  // sourcery: model=Kategory, modelPrimaryKey=categoryId, collection, unwrap=[]
  var categories: [BaseKategory]? { get }
  // sourcery: model=Story, dictionary=Int, unwrap=[:]
  var stories: [Int: BaseStory]? { get }
}
