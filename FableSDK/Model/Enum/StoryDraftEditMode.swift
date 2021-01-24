//
//  StoryDraftEditMode.swift
//  FableSDKEnums
//
//  Created by Andrew Aquino on 12/12/20.
//

import Foundation

public enum StoryDraftEditMode: Equatable {
  case selectedMessage(messageId: Int)
  case normal
}
