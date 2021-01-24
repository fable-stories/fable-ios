//
//  SignalProducer+Extensions.swift
//  App
//
//  Created by Andrew Aquino on 2/18/19.
//

import Foundation
import AppFoundation
import ReactiveSwift

extension SignalProducer {
  public static func singleValue(_ value: Value) -> SignalProducer<Value, Error> {
    return SignalProducer<Value, Error>(value: value)
  }
  
  public func onMain() -> Self {
    return observe(on: QueueScheduler.main)
  }
  
  public func mapVoid() -> SignalProducer<(), Error> {
    return map { _ in () }
  }
  
  public static func delayedProducer(_ delay: TimeInterval) -> SignalProducer<Void, Never> {
    return SignalProducer<Void, Never>.init(value: ())
      .delay(delay, on: QueueScheduler.main)
  }
  
  public func mapErrorException() -> SignalProducer<Value, Exception> {
    mapError { Exception($0) }
  }

  public func skipError() -> SignalProducer<Value, Never> {
    return flatMapError { _ -> SignalProducer<Value, Never> in
      return SignalProducer<Value, Never>.empty
    }
  }
  
  public func gated(when boolProperty: Property<Bool>) -> SignalProducer<Value, Error> {
    return gated(when: boolProperty.producer)
  }

  public func gated(when boolProperty: SignalProducer<Bool, Never>) -> SignalProducer<Value, Error> {
    return flatMap(.latest) { value in
      return SignalProducer<Value, Error> { observer, lifetime in
        boolProperty.producer.take(duringLifetimeOf: lifetime).startWithValues { shouldGate in
          if !shouldGate {
            observer.send(value: value)
          }
        }
      }
    }
  }
}

extension SignalProducer where Error == Never {
  public func property(initial: Value) -> Property<Value> {
    return Property<Value>(initial: initial, then: self)
  }
}
