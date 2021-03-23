//
//  RKPresenter.swift
//  Fable
//
//  Created by Andrew Aquino on 12/22/19.
//

import AppFoundation
import FableSDKResolver
import FableSDKModelManagers
import FableSDKModelObjects
import FableSDKModelPresenters
import FableSDKResourceTargets
import Foundation
import ReactiveSwift


public class RKPresenter {
  public let onUpdate: Signal<Void, Never>
  private let onUpdateObserver: Signal<Void, Never>.Observer
  
  private let resolver: FBSDKResolver
  private let dataStoreManager: DataStoreManager
  private let resourceManager: ResourceManager

  private var model: DataStore

  public var story: Story { model.story }
  public private(set) var currentChapterId: Int
  public private(set) var messageGroups: [MessageGroup] = []
  public private(set) var messages: [Message] = []

  public init?(
    resolver: FBSDKResolver,
    model: DataStore
  ) {
    guard let firstChapterId = model.chapters.values.first?.chapterId else { return nil }
    (self.onUpdate, self.onUpdateObserver) = Signal<Void, Never>.pipe()
    self.resolver = resolver
    self.dataStoreManager = resolver.get()
    self.resourceManager = resolver.get()
    self.currentChapterId = firstChapterId
    self.model = model
    self.messages = model.fetchMessages()
      .compactMap { $0 as? MutableMessage }
      .sorted(by: { lhs, rhs in lhs.displayIndex < rhs.displayIndex })
      .filter { $0.text.isNotEmpty }
      .map { $0.hydrate(model: model) }
  }
}
