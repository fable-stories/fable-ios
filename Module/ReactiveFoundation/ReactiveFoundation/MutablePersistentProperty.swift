//
//  MutablePersistentProperty.swift
//  ModernDatingSucks
//
//  Created by Andrew Aquino on 2/18/19.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa

public protocol MutablePersistentPropertyDelegate: class {
  func mutablePersistentProperty<T, V>(
    interceptAndSwapReturnValue value: T,
    property: MutablePersistentProperty<T>
  ) -> V
}

public final class MutablePersistentProperty<T>:
  ComposableMutablePropertyProtocol
where T: Codable, T: Equatable {
  public typealias Value = T

  private let key: String
  private let initialValue: T

  private lazy var mutableValue = MutableProperty<T>(initialValue)
  public var value: T {
    get { delegate?.mutablePersistentProperty(interceptAndSwapReturnValue: mutableValue.value, property: self) ?? mutableValue.value }
    set { mutableValue.value = newValue }
  }
  
  public private(set) lazy var producer: SignalProducer<T, Never> = mutableValue.producer
  public private(set) lazy var signal: Signal<T, Never> = mutableValue.signal
  
  public var lifetime: Lifetime { mutableValue.lifetime }
  
  public weak var delegate: MutablePersistentPropertyDelegate?

  public init(_ value: T, key: String) {
    self.key = key
    
    self.initialValue = {
      if let initialData = UserDefaults.standard.value(forKey: key) as? Data,
        let value = try? JSONDecoder().decode(T.self, from: initialData) {
        return value
      }
      return value
    }()

    self.mutableValue.signal.take(duringLifetimeOf: self).observeValues { value in
      if let data = try? JSONEncoder().encode(value) {
        UserDefaults.standard.setValue(data, forKey: key)
        UserDefaults.standard.synchronize()
      }
    }
  }
  
  public func withValue<Result>(_ action: (T) throws -> Result) rethrows -> Result {
    try mutableValue.withValue(action)
  }
  
  public func modify<Result>(_ action: (inout T) throws -> Result) rethrows -> Result {
    try mutableValue.modify(action)
  }
}

