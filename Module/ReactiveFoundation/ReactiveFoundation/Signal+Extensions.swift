//
//  Signal+Extensions.swift
//  ReactiveFoundation
//
//  Created by Andrew Aquino on 4/28/19.
//

import Foundation
import ReactiveSwift
import AppFoundation

extension Signal {
  public func prefix(value: Value) -> Signal<Value, Error> {
    return Signal<Value, Error> { [weak self] observer, lifetime in
      observer.send(value: value)
      lifetime += self?.producer.prefix(value: value).startWithSignal { signal, diposable in
        return lifetime += signal.observe { event in
          observer.send(event)
        }
      }
    }
  }
  /**
   * Forward the latest value on `scheduler` after at least `interval`
   * seconds have passed since *the returned signal* last sent a value.
   * Updates on `interval` seconds replaces the debounce signal.
   */
  public func debounce(_ interval: Property<TimeInterval>, on scheduler: DateScheduler) -> Signal<Value, Error> {
    return Signal<Value, Error> { [weak self] observer, lifetime in
      let (innerValueSignal, innerValueObserver) = Signal<Value, Never>.pipe()
      var disposable: Disposable?
      // keep a reference of the latest value just in case innerValueSignal get's disposed
      // right before an actual value is sent
      var latestValue: Value?
      interval.producer.take(during: lifetime).startWithValues { interval in
        if let latestValue = latestValue {
          observer.send(value: latestValue)
        }
        disposable?.dispose()
        disposable = innerValueSignal
          .take(during: lifetime)
          .debounce(interval, on: scheduler)
          .observeValues { value in
            observer.send(value: value)
          }
      }
      self?.producer.take(during: lifetime).start { event in
        if let value = event.value {
          latestValue = value
          innerValueObserver.send(value: value)
        } else {
          observer.send(event)
        }
      }
    }
  }
  
  public func onMain() -> Signal<Value, Error> {
    return observe(on: QueueScheduler.main)
  }

  public func mapVoid() -> Signal<(), Error> {
    return map { _ in () }
  }

  public func optionalize() -> Signal<Value?, Error> {
    return map { Optional<Value>($0) }
  }
  
  public func startWithValue(_ initial: Value) -> SignalProducer<Value, Error> {
    return SignalProducer<Value, Error> { [weak self] observer, _ in
      self?.observe { event in
        observer.send(event)
      }
      observer.send(value: initial)
    }
  }
  
  /// Do not forward any values while the given property remains true.
  public func gate<T: PropertyProtocol>(while property: T) -> Signal<Value, Error> where T.Value == Bool {
    filter { _ in !property.value }
  }
}
