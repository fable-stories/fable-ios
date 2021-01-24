//
//  Message+Extension.swift
//  FableSDKModelObjects
//
//  Created by Andrew Aquino on 1/6/20.
//

import Foundation

extension MutableMessage {
  public func hydrate(model: CKModelReadOnly) -> Self {
    self.character = self.characterId.flatMap(model.fetchCharacter(characterId:))
    return self
  }
  
  public var hasModifier: Bool {
    characterId != nil || choiceGroup != nil
  }
}

extension Array where Element == Message {
  public var messageIds: Set<Int> {
    Set(map { $0.messageId })
  }
}
