//
//  MutableProperty+Extensions.swift
//  ReactiveFoundation
//
//  Created by Andrew Aquino on 9/12/19.
//

import Foundation

import ReactiveSwift

extension MutableProperty {
  public func property() -> Property<Value> {
    return Property<Value>(capturing: self.map { $0 })
  }
}
