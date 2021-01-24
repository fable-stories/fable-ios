//
//  Environment.swift
//  Fable
//
//  Created by Andrew Aquino on 12/13/19.
//

import Foundation

public enum Environment: Codable, CustomStringConvertible {
  private enum CodingKeys: String, CodingKey  {
    case value
  }
  
  case proxy(String)
  case local
  case dev
  case stage
  case prod
  
  public var description: String {
    switch self {
    case .local: return "local"
    case .dev: return "dev"
    case .stage: return "stage"
    case .prod: return "prod"
    case .proxy(let url): return url
    }
  }
  
  public init(rawValue value: String) {
    switch value {
    case "local": self = .local
    case "dev": self = .dev
    case "stage": self = .stage
    case "prod": self = .prod
    default: self = .proxy(value)
    }
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let env = try values.decode(String.self, forKey: .value)
    self = Environment(rawValue:  env)
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(description, forKey: .value)
  }
}
