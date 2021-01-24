//
//  WireConfig.swift
//  Fable
//
//  Created by Andrew Aquino on 8/19/19.
//

import Foundation
import NetworkFoundation

// public struct WireConfig: Codable {
//  public let colorHexStrings: [String]?
//  public let categories: [WireKategory]?
// }

public struct WireResourcesConfig: Codable {
  public struct WireStoryConfig: Codable {}
}

public struct WireScreensConfig: Codable {
  public let home: WireHomeScreenConfig?
}

public struct WireHomeScreenConfig: Codable {
  public let featuredStories: [WireFeaturedStoryConfig]?
  public let categories: [WireKategoryConfig]?
}

public struct WireFeaturedStoryConfig: Codable {
  public let storyId: Int?
  public let index: Int?
}

public struct WireKategoryConfig: Codable {
  public let categoryId: Int?
  public let index: Int?
}
