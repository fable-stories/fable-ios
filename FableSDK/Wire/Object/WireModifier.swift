//
//  WireModifier.swift
//  Fable
//
//  Created by Andrew Aquino on 10/8/19.
//

import AppFoundation
import FableSDKEnums
import Foundation

public struct WireModifier: Codable, InitializableWireObject {
  public let modifierId: Int?
  public let modifiedId: Int?
  public let modifierKind: ModifierKind?
}
