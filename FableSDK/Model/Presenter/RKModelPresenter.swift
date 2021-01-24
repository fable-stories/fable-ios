//
//  RKModelPresenter.swift
//  Fable
//
//  Created by Andrew Aquino on 12/22/19.
//

import AppFoundation
import FableSDKResolver
import FableSDKModelObjects
import FableSDKResourceTargets
import Foundation
import ReactiveSwift

public struct MissingFieldError: LocalizedError {
  public let localizedDescription: String
  public let errorDescription: String?
  public init(_ localizedDescription: String) {
    self.errorDescription = localizedDescription
    self.localizedDescription = localizedDescription
  }
}

public protocol LinkedListElement {
  var linkedListId: Int { get }
  var previousLinkedListId: Int? { get }
  var nextLinkedListId: Int? { get }
  func setNext(_ nextId: Int?)
  func setPrevious(_ previousId: Int?)
  func getPrevious<T: LinkedListElement>(_ linkedList: LinkedList<T>) -> T?
  func getNext<T: LinkedListElement>(_ linkedList: LinkedList<T>) -> T?
}

public struct LinkedList<T: LinkedListElement> {
  public private(set) var list: [T] = []

  public init(dict: [Int: T] = [:]) {
    rebuild(dict: dict)
  }

  public mutating func rebuild(dict: [Int: T]) {
    if let first = dict.values.first(where: { $0.previousLinkedListId == nil }) {
      var curr: T! = first
      while curr != nil {
        list.append(curr)
        curr = curr.nextLinkedListId.flatMap { dict[$0] }
      }
    }
  }

  public mutating func append(_ element: T) {
    if let previous = list.last {
      previous.setNext(element.linkedListId)
      element.setPrevious(previous.linkedListId)
    }
    list.append(element)
  }
}
