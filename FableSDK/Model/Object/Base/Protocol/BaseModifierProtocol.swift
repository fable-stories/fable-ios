//
//  BaseModifierProtocol.swift
//  FableSDKModelObjects
//
//  Created by Andrew Aquino on 1/9/20.
//

import FableSDKEnums
import NetworkFoundation
import ReactiveSwift
import UIKit

public protocol BaseModifierProtocol: Codable {
  var modifierId: Int { get }
  var modifierKind: ModifierKind { get }
  var userId: Int { get }
  var storyId: Int { get }
}
