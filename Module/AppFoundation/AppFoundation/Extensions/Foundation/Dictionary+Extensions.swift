//
//  Dictionary+Extensions.swift
//  AppFoundation
//
//  Created by Andrew Aquino on 5/29/19.
//

import Foundation

extension Dictionary {
  public func compactMapKeysAndValues<T, V>(_ transform: (Key, Value) -> (T?, V?)) -> Dictionary<T, V> {
    return Dictionary<T, V>(uniqueKeysWithValues: compactMap {
      guard let (newKey, newValue) = transform($0, $1) as? (T, V) else { return nil }
      return (newKey, newValue)
    })
  }
  
  public func mapObject<T>(_ objectType: T.Type) -> T? where T: Codable {
    if let data = try? JSONSerialization.data(withJSONObject: self, options: []),
      let object = try? JSONDecoder().decode(objectType.self, from: data) {
      return object
    }
    return nil
  }
  
  public func keyMap(_ keys: [Key]) -> [Value] {
    return keys.compactMap { self[$0] }
  }
}

extension Dictionary {
  public mutating func inserting(key: Key, value: Value) -> Self {
    self[key] = value
    return self
  }
}
