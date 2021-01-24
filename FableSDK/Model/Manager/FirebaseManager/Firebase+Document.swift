//
//  Firebase+Document.swift
//  Fable
//
//  Created by Andrew Aquino on 4/8/19.
//

import Foundation

public protocol FirebaseDocument: Codable {
  static var collection: String { get }
  var documentId: Int { get }
  func json() -> [String: Any]
}
