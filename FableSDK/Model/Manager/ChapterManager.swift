//
//  ChapterManager.swift
//  FableSDKModelManagers
//
//  Created by Andrew Aquino on 11/28/20.
//

import Foundation
import AppFoundation
import Combine
import FableSDKModelObjects
import FableSDKResourceTargets

public protocol ChapterManager {
  func fetchById(chapterId: Int) -> Chapter?
  func findById(chapterId: Int) -> AnyPublisher<Chapter?, Exception>
  func listByStoryId(storyId: Int) -> AnyPublisher<[Chapter], Exception>
}

public class ChapterManagerImpl: ChapterManager {
  private let networkManager: NetworkManagerV2
  
  private var chapterById: [Int: Chapter] = [:]

  public init(networkManager: NetworkManagerV2) {
    self.networkManager = networkManager
  }
  
  public func fetchById(chapterId: Int) -> Chapter? {
    chapterById[chapterId]
  }
  
  public func findById(chapterId: Int) -> AnyPublisher<Chapter?, Exception> {
    self.networkManager.request(GetDraftChapter(chapterId: chapterId))
      .map { [weak self] wire in
        if let chapter = wire.flatMap(Chapter.init(wire:)) {
          self?.chapterById[chapter.chapterId] = chapter
          return chapter
        }
        return nil
      }
      .eraseToAnyPublisher()
  }
  
  public func listByStoryId(storyId: Int) -> AnyPublisher<[Chapter], Exception> {
    self.networkManager.request(
      RefreshChapters(storyId: storyId)
    ).map { [weak self] wire in
      if let chapters = wire?.items.compactMap(Chapter.init(wire:)) {
        for chapter in chapters {
          self?.chapterById[chapter.chapterId] = chapter
        }
        return chapters
      }
      return []
    }
    .eraseToAnyPublisher()
  }
}
