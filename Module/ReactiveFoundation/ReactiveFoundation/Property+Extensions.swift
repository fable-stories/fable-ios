//
//  Property+Extensions.swift
//  ReactiveFoundation
//
//  Created by Andrew Aquino on 9/12/19.
//

import Foundation
import ReactiveSwift

public extension Property where Value: Sequence {
  func combineLatest<T: Sequence, V>(
    byKey: @escaping (Value.Element) -> Property<T>
  ) -> Property<[V]> {
    return flatMap(.latest) { value -> Property<[V]> in
      let properties: [Property<T>] = value.map(byKey)
      guard let combine = Property<[[T]]>.combineLatest(properties) else {
        return Property<[V]>(value: Array<V>())
      }
      return combine.map { combine in
        if let result = (combine.flatMap { $0 }) as? [V] {
          return result
        }
        return []
      }
    }
  }
}
