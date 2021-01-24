//
//  WorkspaceManager+CKModelManager.swift
//  FableSDKViewPresenters
//
//  Created by Andrew Aquino on 12/27/19.
//

import AppFoundation
import FableSDKUIFoundation
import FableSDKEnums
import FableSDKModelManagers
import FableSDKModelObjects
import UIKit


extension WorkspaceManager {

  public func refreshStory() {
    modelManager.refreshStory()
  }

  public func saveStory() {
    modelManager.saveStory()
  }

  public func removeStory() {
    modelManager.removeStory()
  }

  public func uploadStoryImage(_ image: UIImage, forKey key: ImageKey, _ callback: @escaping () -> Void = { return }) {
    modelManager.uploadStoryImage(image, forKey: key, callback)
  }

  public func publishStory() {
    modelManager.publishStory()
  }

  public func unpublishStory() {
    modelManager.unpublishStory()
  }

  public func refreshChapters() {
    modelManager.refreshChapters()
  }

  public func appendNewMessageGroup() {}

  public func deleteMessageGroup(messageGroupId: Int) {}

  public func refreshMessageGroups() {
    modelManager.refreshMessageGroups()
  }

  public func saveMessageGroups() {}
  
  // MARK: MESSAGES
  
  public func nextMessage(textInput: String) {
  }

  public func removeMessage(previousMessageId: Int?, messageId: Int) {
    self.modelManager.removeMessage(previousMessageId: previousMessageId, messageId: messageId)
  }
  
  public func updateMessage(
    messageId: Int,
    text: String? = nil,
    displayIndex: Int? = nil,
    active: Bool? = nil
  ) {
    modelManager.updateMessage(
      messageId: messageId,
      text: text,
      displayIndex: displayIndex,
      active: active
    )
  }

  public func saveMessages(messageIds: Set<Int>) {
    for message in fetchMessages(messageIds: messageIds) {
      updateMessage(
        messageId: message.messageId,
        text: message.text
      )
    }
  }
  
  // MARK: Characters

  public func appendNewCharacter() {
    guard let colorHexString = colorHexStrings.randomElement() else { return }
    modelManager.appendNewCharacter(colorHexString: colorHexString)
  }

  public func removeCharacter(characterId: Int) {
    modelManager.removeCharacter(characterId: characterId)
  }
  
  public func refreshCharacters() {}
  
  public func updateCharacter(
    characterId: Int,
    name: String? = nil,
    colorHexString: String? = nil,
    messageAlignment: MessageAlignment? = nil
  ) {
    modelManager.updateCharacter(
      characterId: characterId,
      name: name,
      colorHexString: colorHexString,
      messageAlignment: messageAlignment
    )
  }

  public func attachChoiceGroup() {
    guard
      let chapterId = selectedChapter?.chapterId,
      let messageGroupId = selectedMessageGroups.last?.messageGroupId,
      let messageId = selectedMessage?.messageId
    else { return }

    // can only attach choice group to last message
//    guard let message = fetchMessage(messageId: messageId), let messageGroup = fetchMessageGroup(messageGroupId: message.messageGroupId), messageGroup.messageIds.last == message.messageId else {
//      onErrorObserver.send(value: ConditionalError("Can only attach choice modifier to last message."))
//      return
//    }

    guard

      // create the choice group and grab the first choice
      let choiceGroup = modelManager.attachChoiceGroup(
        userId: modelManager.story.userId,
        chapterId: chapterId,
        messageGroupId: messageGroupId,
        toMessageId: messageId
      ),
      let firstChoice = choiceGroup.choices.first

    else { return }

    // update the choice model
//    choiceModel.setChoiceGroup(choiceGroup: choiceGroup, model: model)

    // select that choice in the editor to present as it is newly created
    setSelected(.choice(choiceId: firstChoice.choiceId))

    // publish
    commitEditEvents()
  }

  public func attachCharacterToMessage(messageId: Int, characterId: Int) {
    modelManager.attachCharacterToMessage(characterId: characterId, messageId: messageId)
  }

  public func detachCharacterFromMessage(messageId: Int, characterId: Int) {
    modelManager.detachCharacterFromMessage(characterId: characterId, messageId: messageId)
  }
}
