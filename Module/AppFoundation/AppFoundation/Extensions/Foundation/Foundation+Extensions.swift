//
//  Foundation+Extensions.swift
//  AppFoundation
//
//  Created by Andrew Aquino on 3/27/19.
//

import Foundation

extension Array {
  public init(_ count: Int, repeatInstancesOf: @escaping () -> Element) {
    self = (0 ..< count).map { _ in repeatInstancesOf() }
  }
}

extension String {
  public func toAttributedString(_ attributes: Dictionary<NSAttributedString.Key, Any> = [:]) -> NSAttributedString {
    return NSAttributedString(string: self, attributes: attributes)
  }
  
  public func toMutableAttributedString(_ attributes: Dictionary<NSAttributedString.Key, Any> = [:]) -> NSMutableAttributedString {
    return NSMutableAttributedString(string: self, attributes: attributes)
  }
}

public func envString(_ key: String) -> String? {
  if let value = ProcessInfo.processInfo.environment[key.uppercased()] {
    return value
  }
  return nil
}

public func envStringArray(_ key: String) -> [String]? {
  if let value = ProcessInfo.processInfo.environment[key.uppercased()] {
    return value.components(separatedBy: ",")
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
  }
  return nil
}

public func envInt(_ key: String) -> Int? {
  if let value = ProcessInfo.processInfo.environment[key.uppercased()], let int = Int(value) {
    return int
  }
  return nil
}

public func envBool(_ key: String) -> Bool? {
  if let value = ProcessInfo.processInfo.environment[key.uppercased()] {
    switch value.lowercased() {
    case "yes", "true": return true
    case "no", "false": return false
    default: return Bool(value)
    }
  }
  return nil
}
