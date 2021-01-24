// Generated using Sourcery 0.18.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import AppFoundation
import FableSDKEnums
// swiftlint:disable all
import Foundation

extension GoogleSignInRequest {
  public init(
    rawIdToken: String? = nil,
    _: Void? = nil
  ) {
    self.rawIdToken = rawIdToken
  }
}

extension GoogleSignInRequest: CustomStringConvertible {
  public var description: String { prettyJSONString }
}

extension SignInRequest {
  public init(
    email: String? = nil,
    password: String? = nil,
    refreshToken: String? = nil,
    _: Void? = nil
  ) {
    self.email = email
    self.password = password
    self.refreshToken = refreshToken
  }
}

extension SignInRequest: CustomStringConvertible {
  public var description: String { prettyJSONString }
}

extension SignInResponse {
  public init(
    authentication: WireAuthentication? = nil,
    user: WireUser? = nil,
    _: Void? = nil
  ) {
    self.authentication = authentication
    self.user = user
  }
}

extension SignInResponse: CustomStringConvertible {
  public var description: String { prettyJSONString }
}

extension WireAuthentication {
  public init(
    idToken: String? = nil,
    refreshToken: String? = nil,
    expiresIn: String? = nil,
    isNewUser: Bool? = nil,
    _: Void? = nil
  ) {
    self.idToken = idToken
    self.refreshToken = refreshToken
    self.expiresIn = expiresIn
    self.isNewUser = isNewUser
  }
}

extension WireAuthentication: CustomStringConvertible {
  public var description: String { prettyJSONString }
}

extension WireCollectionRemoveById {
  public init(
    collection: String? = nil,
    modelId: Int? = nil,
    _: Void? = nil
  ) {
    self.collection = collection
    self.modelId = modelId
  }
}

extension WireCollectionRemoveById: CustomStringConvertible {
  public var description: String { prettyJSONString }
}

extension WireCreateCategoryRequestBody {
  public init(
    name: String? = nil,
    _: Void? = nil
  ) {
    self.name = name
  }
}

extension WireCreateCategoryRequestBody: CustomStringConvertible {
  public var description: String { prettyJSONString }
}

extension WireModifier {
  public init(
    modifierId: Int? = nil,
    modifiedId: Int? = nil,
    modifierKind: ModifierKind? = nil,
    _: Void? = nil
  ) {
    self.modifierId = modifierId
    self.modifiedId = modifiedId
    self.modifierKind = modifierKind
  }
}

extension WireModifier: CustomStringConvertible {
  public var description: String { prettyJSONString }
}

extension WireRichCollection {
  public init(
    story: WireStory? = nil,
    chapter: WireChapter? = nil,
    chapters: [WireChapter]? = nil,
    messageGroups: [WireMessageGroup]? = nil,
    messages: [WireMessage]? = nil,
    characters: [WireCharacter]? = nil,
    _: Void? = nil
  ) {
    self.story = story
    self.chapter = chapter
    self.chapters = chapters
    self.messageGroups = messageGroups
    self.messages = messages
    self.characters = characters
  }
}

extension WireRichCollection: CustomStringConvertible {
  public var description: String { prettyJSONString }
}

extension WireUpdateCategoryRequestBody {
  public init(
    name: String? = nil,
    _: Void? = nil
  ) {
    self.name = name
  }
}

extension WireUpdateCategoryRequestBody: CustomStringConvertible {
  public var description: String { prettyJSONString }
}
