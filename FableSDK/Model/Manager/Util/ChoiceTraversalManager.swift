//
//  ChoiceTraversalManager.swift
//  Fable
//
//  Created by Andrew Aquino on 11/6/19.
//

import AppFoundation
import FableSDKModelObjects
import Foundation
import ReactiveCocoa
import ReactiveSwift
import SnapKit

public class ChoiceTraversalManager {
  public class Node {
    public let identifier: Int
    private var children = Stack<Node>()

    public func next() -> Node? {
      children.pop()
    }

    public func copy() -> Node {
      Node(
        identifier: identifier,
        children: Stack<Node>(array: children.array.map { $0.copy() })
      )
    }

    private init(
      identifier: Int,
      children: Stack<Node>
    ) {
      self.identifier = identifier
      self.children = children
    }

    public init(
      mc: MessageGroup,
      mcs: [Int: MessageGroup]
    ) {
      self.identifier = mc.messageGroupId
//      let choices = mc.choiceGroup.value?.mutableChoices.value ?? []
//      for choice in choices {
//        self.children.push(Node(choice: choice, mcs: mcs))
//      }
    }

    public init(
      choice: Choice,
      mcs: [Int: MessageGroup]
    ) {
      self.identifier = choice.choiceId
//      if let targetId = choice.mutableTargetMessageGroupId.value, let mc = mcs[targetId] {
//        self.children.push(Node(mc: mc, mcs: mcs))
//      }
    }
  }

  private var stack = Stack<Node>()
  private var capturedStacks: [Stack<Node>] = []
  private var cachedCapturedStacks: [Int: [Stack<Node>]] = [:]

  private let messageGroups: Property<[MessageGroup]>
  private lazy var mcDict: Property<[Int: MessageGroup]> = messageGroups
    .map { $0.indexed(by: { $0.messageGroupId }) }

  public init(
    messageGroups: Property<[MessageGroup]>
  ) {
    self.messageGroups = messageGroups
  }

  public func sourceId(leadingTo targetId: Int) -> Int? {
    traverseChoices(leadingTo: targetId, skipCache: true)
    guard var nodes = capturedStacks.first?.array.map({ $0.copy() }), nodes.isNotEmpty else { return nil }
    nodes.removeLast()
    return nodes.last?.identifier
  }

  public func traverseChoices(leadingTo targetId: Int) -> [Set<Int>] {
    traverseChoices(leadingTo: targetId, skipCache: false)
  }

  @discardableResult
  private func traverseChoices(leadingTo targetId: Int, skipCache: Bool) -> [Set<Int>] {
    // fast return on cached captured stacks
    if let cached = cachedCapturedStacks[targetId], cached.isNotEmpty, !skipCache {
      return mapStacksIntoSets(stacks: cached)
    }
    // setup new traversal data structures
    guard let rootMc = messageGroups.value.first else { return [] }
    capturedStacks.removeAll()
    stack.removeAll()
    stack.push(Node(mc: rootMc, mcs: mcDict.value))
    // begin traversal
    traverse(targetId: targetId)
    // return captured stacks
    return mapStacksIntoSets(stacks: capturedStacks)
  }

  public func buildTree() {
    stack.removeAll()
    capturedStacks.removeAll()
    cachedCapturedStacks.removeAll()
  }

  private func traverse(targetId: Int) {
    if stack.isEmpty { return }
    guard let current = stack.top else { return }
    if current.identifier == targetId {
      cachedCapturedStacks[targetId, default: []].append(stack)
      capturedStacks.append(stack)
      stack.pop()
    } else if let next = current.next() {
      stack.push(next)
    } else {
      stack.pop()
    }
    traverse(targetId: targetId)
  }

  private func mapStacksIntoSets(stacks: [Stack<Node>]) -> [Set<Int>] {
    stacks.map { Set($0.array.map { $0.identifier }) }
  }
}

extension ChoiceTraversalManager.Node: CustomStringConvertible {
  public var description: String {
    "\(identifier)"
  }
}

extension Array where Element == Set<Int> {
  public func childContains(_ element: Int) -> Bool {
    contains { $0.contains(element) }
  }

  public func childEquals(_ set: Set<Int>) -> Bool {
    contains { $0 == set }
  }
}
