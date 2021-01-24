//
//  BaseConfig.swift
//  FableSDKModelObjects
//
//  Created by Andrew Aquino on 1/6/20.
//

import AppFoundation
import Foundation

public protocol BaseConfig: ModelObject, WireObject {
  var configId: Int { get }
  // sourcery: model=Kategory, collection, modelPrimaryKey=categoryId
  var categories: [BaseKategory]? { get }
  // sourcery: unwrap=[]
  var colorHexStrings: [String]? { get }
  // sourcery: unwrap=false
  var enableInteractiveStories: Bool? { get }
  // sourcery: unwrap=[]
  var admins: [String]? { get }
  // sourcery: model=ResourceConfig
  var resourceConfig: BaseResourceConfig? { get }
}
