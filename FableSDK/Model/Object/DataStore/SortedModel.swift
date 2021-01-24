//
//  SortedModel.swift
//  FableSDKModelObjects
//
//  Created by Andrew Aquino on 12/25/19.
//

import AppFoundation
import Foundation
import ReactiveSwift

public class SortedModel {
  private let model: CKModelReadOnly

  public init(model: CKModelReadOnly) {
    self.model = model
  }

  // MARK: - MESSAGE GROUP

  /*

    @discardableResult
    public func link(sourceMessageGroupid: String, targetMessageGroupId: Int) -> Set<String> {
      guard let aMessageGroup = model.fetchMessageGroup(messageGroupId: targetMessageGroupId)
        else { return [] }
      guard let bMessageGroup = model.fetchMessageGroup(messageGroupId: sourceMessageGroupId)
        else { return [] }
      let cMessageGroup = model.fetchMessageGroup(messageGroupId: aMessageGroup.nextMessageGroupId)
      let tMessageGroup = model.fetchMessageGroup(messageGroupId: bMessageGroup.previousMessageGroupId)
      let vMessageGroup = model.fetchMessageGroup(messageGroupId: bMessageGroup.nextMessageGroupId)
      // A <---> B <--- > C
      aMessageGroup.nextMessageGroupId = bMessageGroup.messageGroupId // A -> B
      bMessageGroup.previousMessageGroupId = aMessageGroup.messageGroupId // A <- B
      bMessageGroup.nextMessageGroupId = cMessageGroup?.messageGroupId // B -> C
      cMessageGroup?.previousMessageGroupId = bMessageGroup.previousMessageGroupId // B <- C
      // T <---> V
      tMessageGroup?.nextMessageGroupId = vMessageGroup?.messageGroupId // T -> V
      vMessageGroup?.previousMessageGroupId = tMessageGroup?.messageGroupId // T <- V
      return Set([aMessageGroup.messageGroupId, bMessageGroup.messageGroupId, cMessageGroup?.messageGroupId, tMessageGroup?.messageGroupId, vMessageGroup?.messageGroupId].compactMap { $0 })
    }

    @discardableResult
    public func unlink(messageGroupId: Int) -> Set<String> {
      guard let messageGroup = model.fetchMessageGroup(messageGroupId: messageGroupId) else { return [] }
      let previousMessageGroupId = messageGroup.previousMessageGroupId
      let nextMessageGroupId = messageGroup.nextMessageGroupId
      messageGroup.previousMessageGroupId = nil
      messageGroup.nextMessageGroupId = nil
      let aMessageGroup = previousMessageGroupId.flatMap({ model.fetchMessageGroup(messageGroupId: $0) })
      let cMessageGroup = nextMessageGroupId.flatMap({ model.fetchMessageGroup(messageGroupId: $0) })
      aMessageGroup?.nextMessageGroupId = cMessageGroup?.messageGroupId
      cMessageGroup?.previousMessageGroupId = aMessageGroup?.messageGroupId
      return Set([messageGroup.messageGroupId, aMessageGroup?.messageGroupId, cMessageGroup?.messageGroupId].compactMap { $0 })
    }

    public func sortedChapters() -> [Chapter] {
      let chapterIds = model.fetchChapters().map { $0.chapterId }.sortedMap(
        first: { model.fetchChapter(chapterId: $0)?.mutablePreviousChapterId.value == nil },
        next: { model.fetchChapter(chapterId: $0)?.mutableNextChapterId.value }
      )
      return model.fetchChapters(chapterIds: chapterIds)
    }

    /**
     * Magically repairs the links between the given message ids
         */
    public func repairSort(messageGroupIds: Set<Int>) -> [String] {
      let messages = Set(model.fetchMessageGroups(messageGroupIds: messageGroupIds))
      guard messages.isNotEmpty else { return [] }
      let sorted = messages.sorted(by: { $0.createdAt < $1.createdAt })
      var linked: Set<MessageGroup> = []
      var sortedIds: [Int] = []
      var currMessageGroup = sorted.first(where: { $0.previousMessageGroupId.isNilOrEmpty }) ?? sorted.first
      while currMessageGroup != nil {
        linked.insert(currMessageGroup!)
        sortedIds.append(currMessageGroup!.messageGroupId)
        currMessageGroup = model.fetchMessageGroup(messageGroupId: currMessageGroup!.nextMessageGroupId)
      }
      let unlinked = messages.subtracting(linked).sorted(by: { $0.createdAt < $1.createdAt })
      for (index, message) in unlinked.enumerated() {
        if index == 0 {
          messageGroup.previousMessageGroupId = sorted.last?.messageGroupId
        }
        if index + 1 < sorted.count {
          let nextMessageGroup = sorted[index + 1]
          messageGroup.nextMessageGroupId = nextMessageGroup.messageGroupId
          nextMessageGroup.previousMessageGroupId = messageGroup.messageGroupId
        } else {
          messageGroup.nextMessageGroupId = nil
        }
        sortedIds.append(messageGroup.messageGroupId)
      }
      return sortedIds
    }
   */

  // MARK: - MESSAGE

  /**
   * Links source message to target message and reattaches links
   * from any of the peripheral ids from both messages.
   *
   * Returns a Set of message ids that have been updated
   *
   * TARGET SET ... SOURCE SET
   * A <---> C ... T <---> B <---> V
   * RESULT SET
   * A <---> B <---> C ... T <---> V
   *
   */
  @discardableResult
  public func link(sourceMessageId: Int, targetMessageId: Int) -> Set<Int> {
    /*
     guard var aMessage = model.fetchMessage(messageId: targetMessageId) else { return [] }
     guard var bMessage = model.fetchMessage(messageId: sourceMessageId) else { return [] }
     var cMessage = aMessage.nextMessageId.flatMap { model.fetchMessage(messageId: $0) }
     var tMessage = bMessage.previousMessageId.flatMap { model.fetchMessage(messageId: $0) }
     var vMessage = bMessage.nextMessageId.flatMap { model.fetchMessage(messageId: $0) }
     // A <---> B <--- > C
     aMessage = aMessage.copy(nextMessageId: bMessage.messageId) // A -> B
     bMessage.previousMessageId = aMessage.messageId // A <- B
     bMessage.nextMessageId = cMessage?.messageId // B -> C
     cMessage?.previousMessageId = bMessage.previousMessageId // B <- C
     // T <---> V
     tMessage?.nextMessageId = vMessage?.messageId // T -> V
     vMessage?.previousMessageId = tMessage?.messageId // T <- V
     return Set([aMessage.messageId, bMessage.messageId, cMessage?.messageId, tMessage?.messageId, vMessage?.messageId].compactMap { $0 })
      */
    []
  }

  @discardableResult
  public func unlink(messageId: Int) -> Set<Int> {
//    guard let message = model.fetchMessage(messageId: messageId) else { return [] }
//    let previousMessageId = message.previousMessageId
//    let nextMessageId = message.nextMessageId
//    message.previousMessageId = nil
//    message.nextMessageId = nil
//    let aMessage = previousMessageId.flatMap({ model.fetchMessage(messageId: $0) })
//    let cMessage = nextMessageId.flatMap({ model.fetchMessage(messageId: $0) })
//    aMessage?.nextMessageId = cMessage?.messageId
//    cMessage?.previousMessageId = aMessage?.messageId
//    return Set([message.messageId, aMessage?.messageId, cMessage?.messageId].compactMap { $0 })
    []
  }

  public func sortedChapters() -> [Chapter] {
    let chapterIds = model.fetchChapters().map { $0.chapterId }.sortedMap(
      first: { model.fetchChapter(chapterId: $0)?.previousChapterId == nil },
      next: { model.fetchChapter(chapterId: $0)?.nextChapterId }
    )
    return model.fetchChapters(chapterIds: chapterIds)
  }

  /**
   * Magically repairs the links between the given message ids
   */
  public func repairSort(messageIds: Set<Int>) -> [Int] {
//    let messages = Set(model.fetchMessages(messageIds: messageIds))
//    guard messages.isNotEmpty else { return [] }
//    let sorted = messages.sorted(by: { $0.createdAt < $1.createdAt })
//    var linked: Set<Message> = []
//    var sortedIds: [Int] = []
//    var currMessage = sorted.first(where: { $0.previousMessageId.isNil }) ?? sorted.first
//    while currMessage != nil {
//      linked.insert(currMessage!)
//      sortedIds.append(currMessage!.messageId)
//      currMessage = currMessage!.nextMessageId.flatMap { model.fetchMessage(messageId: $0) }
//    }
//    let unlinked = messages.subtracting(linked).sorted(by: { $0.createdAt < $1.createdAt })
//    for (index, message) in unlinked.enumerated() {
//      if index == 0 {
//        message.previousMessageId = sorted.last?.messageId
//      }
//      if index + 1 < sorted.count {
//        let nextMessage = sorted[index + 1]
//        message.nextMessageId = nextMessage.messageId
//        nextMessage.previousMessageId = message.messageId
//      } else {
//        message.nextMessageId = nil
//      }
//      sortedIds.append(message.messageId)
//    }
//    return sortedIds
    []
  }

  /**
   * Magically repairs the links between the given message group ids
   */
  public func repairSort(messageGroups: [MessageGroup]) -> [Int] {
//    guard messageGroups.isNotEmpty else { return [] }
//    let sorted = messageGroups.sorted(by: { $0.createdAt < $1.createdAt })
//    var linked: Set<MessageGroup> = []
//    var sortedIds: [Int] = []
//    var curr = sorted.first(where: { $0.previousMessageGroupId.isNil }) ?? sorted.first
//    while curr != nil {
//      linked.insert(curr!)
//      sortedIds.append(curr!.messageGroupId)
//      curr = curr!.nextMessageGroupId.flatMap {
//        model.fetchMessageGroup(messageGroupId: $0)
//      }
//    }
//    let unlinked = Set(messageGroups).subtracting(linked).sorted(by: { $0.createdAt < $1.createdAt })
//    for (index, message) in unlinked.enumerated() {
//      if index == 0 {
//        message.previousMessageGroupId = sorted.last?.messageGroupId
//      }
//      if index + 1 < sorted.count {
//        let nextMessage = sorted[index + 1]
//        message.nextMessageGroupId = nextMessage.messageGroupId
//        nextMessage.previousMessageGroupId = message.messageGroupId
//      } else {
//        message.nextMessageGroupId = nil
//      }
//      sortedIds.append(message.messageGroupId)
//    }
//    return sortedIds
    []
  }

  @discardableResult
  public func link(sourceMessageGroupId: Int, targetGroupMessageId: Int) -> Set<Int> {
//    guard let aMG = model.fetchMessageGroup(messageGroupId: targetGroupMessageId) else { return [] }
//    guard let bMG = model.fetchMessageGroup(messageGroupId: sourceMessageGroupId) else { return [] }
//    let cMG = aMG.nextMessageGroupId.flatMap { model.fetchMessageGroup(messageGroupId: $0) }
//    let tMG = bMG.previousMessageGroupId.flatMap { model.fetchMessageGroup(messageGroupId: $0) }
//    let vMG = bMG.nextMessageGroupId.flatMap { model.fetchMessageGroup(messageGroupId: $0) }
//    // A <---> B <--- > C
//    aMG.nextMessageGroupId = bMG.messageGroupId // A -> B
//    bMG.previousMessageGroupId = aMG.messageGroupId // A <- B
//    bMG.nextMessageGroupId = cMG?.messageGroupId // B -> C
//    cMG?.previousMessageGroupId = bMG.previousMessageGroupId // B <- C
//    // T <---> V
//    tMG?.nextMessageGroupId = vMG?.messageGroupId // T -> V
//    vMG?.previousMessageGroupId = tMG?.messageGroupId // T <- V
//    return Set([aMG.messageGroupId, bMG.messageGroupId, cMG?.messageGroupId, tMG?.messageGroupId, vMG?.messageGroupId].compactMap { $0 })
    []
  }
}
