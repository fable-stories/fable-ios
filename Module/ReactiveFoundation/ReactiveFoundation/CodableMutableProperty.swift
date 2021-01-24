//
//  CodableMutableProperty.swift
//  ReactiveFoundation
//
//  Created by Andrew Aquino on 7/26/19.
//

import Foundation
import ReactiveSwift


public class CodableMutableProperty<T: Codable>: Codable, MutablePropertyProtocol {
  public var lifetime: Lifetime { return mutableValue.lifetime }
  
  private enum CodingKeys: String, CodingKey {
    case value
  }
  
  private lazy var mutableValue = MutableProperty<T>(initialValue)
  
  private let initialValue: T
  
  public var value: T {
    get { return mutableValue.value }
    set { mutableValue.value = newValue }
  }
  
  public private(set) lazy var producer: SignalProducer<T, Never>  = mutableValue.producer
  public private(set) lazy var signal: Signal<T, Never> = mutableValue.signal
  public private(set) lazy var property: Property<T> = Property<T>(initial: initialValue, then: producer)
  
  public init(_ initialValue: T) {
    self.initialValue = initialValue
  }
  
  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.initialValue = try container.decode(T.self, forKey: .value)
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(value, forKey: .value)
  }
}
