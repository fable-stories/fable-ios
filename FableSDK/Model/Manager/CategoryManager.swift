//
//  CategoryManager.swift
//  FableSDKModelManagers
//
//  Created by Andrew Aquino on 12/17/20.
//

import Foundation
import Combine
import AppFoundation
import FableSDKModelObjects
import FableSDKResourceTargets
import FableSDKWireObjects
import NetworkFoundation

public protocol CategoryManager {
  func fetchById(categoryId: Int) -> Kategory?
  func list() -> AnyPublisher<[Kategory], Exception>
  func findById(categoryId: Int) -> AnyPublisher<Kategory?, Exception>
}

public class CategoryManagerImpl: CategoryManager {
  
  private let networkManager: NetworkManagerV2
  
  private var categoryById: [Int: Kategory] = [:]

  public init(networkManager: NetworkManagerV2) {
    self.networkManager = networkManager
  }
  
  public func fetchById(categoryId: Int) -> Kategory? {
    categoryById[categoryId]
  }

  public func list() -> AnyPublisher<[Kategory], Exception> {
    self.networkManager.request(
      path: "/category",
      method: .get
    ).map { [weak self] (wire: WireCollection<WireKategory>) -> [Kategory] in
      let categories = wire.items.compactMap(Kategory.init(wire:))
      for category in categories {
        self?.categoryById[category.categoryId] = category
      }
      return categories
    }.eraseToAnyPublisher().mapException()
  }
  
  public func findById(categoryId: Int) -> AnyPublisher<Kategory?, Exception> {
    self.networkManager.request(
      path: "/category/\(categoryId)",
      method: .get
    ).map { [weak self] (wire: WireKategory?) in
      if let category = wire.flatMap(Kategory.init(wire:)) {
        self?.categoryById[category.categoryId] = category
        return category
      }
      return nil
    }.eraseToAnyPublisher().mapException()
  }
}
