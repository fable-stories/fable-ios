//
//  PersistedProperty.swift
//  AppFoundation
//
//  Created by Andrew Aquino on 1/12/20.
//

import Foundation

public protocol PersistedPropertyDelegate: class {
  func initialValue<T: Codable>(for key: String) throws -> T
  func initialPersistedValue<T: Codable>(for key: String) throws -> T?
  func fetchKey(for propertyKey: String) throws -> String
}

public extension PersistedPropertyDelegate {
  func initialPersistedValue<T: Codable>(for key: String) throws -> T? { nil }
  func fetchKey(for propertyKey: String) throws -> String { propertyKey }
}

public class PersistedProperty<T: Codable> {
  private let initialValue: T
  private var _value: T
  public var value: T {
    get { _value }
    set { _value = newValue; savePersistedValue() }
  }

  public weak var delegate: PersistedPropertyDelegate?
  public let propertyKey: String
  
  public init(_ propertyKey: String, delegate: PersistedPropertyDelegate) {
    self.propertyKey = propertyKey
    self.delegate = delegate
    let initialValue: T = try! delegate.initialValue(for: propertyKey)
    self._value = initialValue
    self.initialValue = initialValue
    self.loadPersistedValue()
  }
  
  public init(_ propertyKey: String, _ initialValue: T) {
    self.propertyKey = propertyKey
    self.initialValue = initialValue
    self._value = initialValue
    self.loadPersistedValue()
  }
  
  public func modify(_ block: (inout T) -> Void) {
    block(&value)
    self.savePersistedValue()
  }
  
  private func savePersistedValue() {
    do {
      let key = try delegate?.fetchKey(for: self.propertyKey) ?? self.propertyKey
      let data = try JSONEncoder().encode(value)
      UserDefaults.standard.setValue(data, forKey: key)
      UserDefaults.standard.synchronize()
    } catch let error {
      print(error)
    }
  }
  
  public func loadPersistedValue() {
    do {
      let key = try delegate?.fetchKey(for: self.propertyKey) ?? self.propertyKey
      if let value: T = try self.delegate?.initialPersistedValue(for: key) {
        self.value = value
      } else if let data = UserDefaults.standard.value(forKey: key) as? Data {
         let value = try JSONDecoder().decode(T.self, from: data)
        self.value = value
      } else if let value: T = try delegate?.initialValue(for: key) {
        self.value = value
      } else {
        self.value = initialValue
      }
    } catch let error {
      print(error)
    }
  }
}
