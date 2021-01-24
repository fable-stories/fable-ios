//
//  StoryEditorNotification.swift
//  FableSDKEnums
//
//  Created by Andrew Aquino on 12/13/20.
//

import Foundation

public protocol ExpressibleByNotificationName {
  var name: Notification.Name { get }
}

public extension RawRepresentable where RawValue == String, Self: ExpressibleByNotificationName {
  var name: Notification.Name { get { return Notification.Name(self.rawValue) } }
}

public enum StoryEditorNotificationName: String, ExpressibleByNotificationName {
  case didSelectCharacter
}

public enum StoryEditorNotification {
  case didSelectCharacter(characterId: Int?)

  public var notification: Notification {
    switch self {
    case .didSelectCharacter(let characterId):
      return Notification(
        name: StoryEditorNotificationName.didSelectCharacter.name,
        object: characterId,
        userInfo: [:]
      )
    }
  }
}

