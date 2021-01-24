//
//  ChoiceModel.swift
//  FableSDKModelManagers
//
//  Created by Andrew Aquino on 1/23/20.
//

import Foundation

private let NULL_CHOICE_ID = -1000
private let NULL_MESSAGE_ID = -1001

public protocol ChoiceModelReadOnly {
  func recursiveSelectedMessageGroupIds(model: CKModelReadOnly) -> [Int]
}

public protocol ChoiceModelWriteOnly {
  func setChoiceGroup(
    choiceGroup: ChoiceGroup,
    model: CKModelReadOnly
  )
  func unsetChoiceGroup(
    choiceGroup: ChoiceGroup,
    model: CKModelReadOnly
  ) -> [Int]
  func selectChoiceId(choiceId: Int)
  func deselectChoiceId(choiceId: Int)
}

public class ChoiceModel: ChoiceModelReadOnly, ChoiceModelWriteOnly {
  public private(set) var rootChoiceNode: ChoiceNode?

  private var choiceGroupIdToChoiceNodeMap: [Int: ChoiceNode] = [:]
  private var choiceIdToChoiceNodeMap: [Int: ChoiceNode] = [:]
  private var choiceIdToParentChoiceNodeMap: [Int: ChoiceNode] = [:]
  private var messageGroupIdToSourceChoiceNodeMap: [Int: ChoiceNode] = [:]

  public init() {}

  // MARK: Read Only

  public func recursiveSelectedMessageGroupIds(model: CKModelReadOnly) -> [Int] {
    rootChoiceNode?.recursiveSelectedMessageGroupIds(model: model) ?? []
  }

  // MARK: Write Only

  public func setChoiceGroup(
    choiceGroup: ChoiceGroup,
    model: CKModelReadOnly
  ) {
    if rootChoiceNode == nil {
      rootChoiceNode = ChoiceNode(
        choiceId: NULL_CHOICE_ID,
        modifiedMessageId: choiceGroup.messageId,
        parentChoiceNodeId: nil
      )
    }
    guard
      let parentChoiceNode = messageGroupIdToSourceChoiceNodeMap[choiceGroup.messageGroupId]
      ?? rootChoiceNode
    else { return }
    // for each choice in the choice group
    parentChoiceNode.choiceNodes = choiceGroup.choices.compactMap { choice in
      guard let targetMessageGroup = choice.targetMessageGroupId.flatMap({
        model.fetchMessages(messageGroupId: $0)
      }), let firstMessageId = targetMessageGroup.messageIds.first else {
        return nil
      }
      let choiceNode = ChoiceNode(
        choiceId: choice.choiceId,
        modifiedMessageId: firstMessageId,
        parentChoiceNodeId: parentChoiceNode.choiceId
      )
      // reference modified message associated to this choice for indexing
      choiceIdToChoiceNodeMap[choiceNode.choiceId] = choiceNode
      choiceIdToParentChoiceNodeMap[choiceNode.choiceId] = parentChoiceNode
      choice.targetMessageGroupId.flatMap { messageGroupIdToSourceChoiceNodeMap[$0] = choiceNode }
      return choiceNode
    }
    choiceIdToChoiceNodeMap[parentChoiceNode.choiceId] = parentChoiceNode
    choiceGroupIdToChoiceNodeMap[choiceGroup.choiceGroupId] = parentChoiceNode
  }

  @discardableResult
  public func unsetChoiceGroup(
    choiceGroup: ChoiceGroup,
    model: CKModelReadOnly
  ) -> [Int] {
    // remove the entire tree if the removed choice group was the root choice group
    if let rootChoiceNode = rootChoiceNode, choiceGroup.messageId == rootChoiceNode.modifiedMessageId {
      // get the list of message groups associated from the root choice group
      self.rootChoiceNode = nil
      choiceGroupIdToChoiceNodeMap.removeAll()
      choiceIdToChoiceNodeMap.removeAll()
      choiceIdToParentChoiceNodeMap.removeAll()
      return rootChoiceNode.choiceNodes.map { $0.recursiveSelectedMessageGroupIds(model: model) }.flatMap { $0 }
    }
    guard let choiceNode = choiceGroupIdToChoiceNodeMap[choiceGroup.choiceGroupId] else { return [] }
    // remove the child from parent (harsh I know.)
    if let parentChoiceNode = choiceIdToParentChoiceNodeMap[choiceNode.choiceId] {
      parentChoiceNode.choiceNodes.removeAll(where: { $0.choiceId == choiceNode.choiceId })
      if parentChoiceNode.selectedChoiceId == choiceNode.choiceId {
        parentChoiceNode.selectedChoiceId = nil
      }
    }
    // remove the node from it's indexes
    choiceGroupIdToChoiceNodeMap[choiceGroup.choiceGroupId] = nil
    // recursively remove all choice ids within this tree
    for choiceId in choiceNode.recursiveChoiceIds {
      choiceIdToChoiceNodeMap[choiceId] = nil
      choiceIdToParentChoiceNodeMap[choiceId] = nil
    }
    return choiceNode.recursiveSelectedMessageGroupIds(model: model)
  }

  public func selectChoiceId(choiceId: Int) {
    guard let parentChoiceNode = choiceIdToParentChoiceNodeMap[choiceId] else { return }
    parentChoiceNode.selectedChoiceId = choiceId
  }

  public func deselectChoiceId(choiceId: Int) {
    guard let parentChoiceNode = choiceIdToParentChoiceNodeMap[choiceId] else { return }
    if parentChoiceNode.selectedChoiceId == choiceId {
      parentChoiceNode.selectedChoiceId = nil
    }
  }
}

public class ChoiceNode {
  public let choiceId: Int
  public let modifiedMessageId: Int
  public var choiceNodes: [ChoiceNode]
  public var selectedChoiceId: Int?
  public var parentChoiceNodeId: Int?

  public init(
    choiceId: Int,
    modifiedMessageId: Int,
    parentChoiceNodeId: Int?
  ) {
    self.choiceId = choiceId
    self.modifiedMessageId = modifiedMessageId
    self.parentChoiceNodeId = parentChoiceNodeId
    self.choiceNodes = []
  }

  public var selectedChoiceNode: ChoiceNode? {
    choiceNodes.first(where: { $0.choiceId == selectedChoiceId })
  }

  public var lastChoiceNode: ChoiceNode? {
    selectedChoiceNode?.lastChoiceNode
  }

  public var recursiveChoiceIds: Set<Int> {
    Set([choiceId] + choiceNodes.reduce([]) { a, i in
      a + i.recursiveChoiceIds
    })
  }

  public func recursiveSelectedMessageGroupIds(model: CKModelReadOnly) -> [Int] {
    let parentMessageGroupIds: [Int] = {
      if let messageGroupId = model.fetchMessage(messageId: modifiedMessageId)?.messageGroupId {
        return [messageGroupId]
      }
      return []
    }()
    if let nextMessageGroupIds = selectedChoiceNode.flatMap({
      $0.recursiveSelectedMessageGroupIds(model: model)
    }) {
      return parentMessageGroupIds + nextMessageGroupIds
    }
    return parentMessageGroupIds
  }

  private func description(depth: Int) -> String {
    let tabs = Array(repeating: "\t", count: depth).joined()
    let tabs2 = Array(repeating: "\t", count: depth > 0 ? depth : 1).joined()
    let children = choiceNodes.map { i in i.description(depth: depth + 1) }.joined(separator: "\n")
    return """
    \(tabs)\(tabs){
    \(tabs2)\(tabs2)\(choiceId): [
    \(children)
    \(tabs2)\(tabs)],
    \(tabs2)\(tabs)selectedChoiceId: \(selectedChoiceId ?? 0)
    \(tabs)\(tabs)}
    """
  }
}

extension ChoiceNode: CustomStringConvertible {
  public var description: String {
    description(depth: 0)
  }
}
