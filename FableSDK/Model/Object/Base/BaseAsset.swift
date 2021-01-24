//
//  BaseAsset.swift
//  FableSDKModelObjects
//
//  Created by MacBook Pro on 8/7/20.
//

import AppFoundation
import Foundation

public protocol BaseAsset: ModelObject {
  var assetId: Int { get }
  var objectUrl: URL { get }
  var tags: [String] { get }
}
