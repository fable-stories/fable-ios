//
//  CKPresenter2.swift
//  FableSDKViewPresenters
//
//  Created by Andrew Aquino on 12/25/19.
//

import AppFoundation
import FableSDKEnums
import FableSDKResolver
import FableSDKModelManagers
import FableSDKModelObjects
import FableSDKModelPresenters
import FableSDKViewInterfaces
import ReactiveSwift
import UIKit


public class WorkspaceManager: NSObject {
  public let resolver: FBSDKResolver
  public let stateManager: StateManager
  internal let appSession: StateManager
  internal let modelManager: CKModelManager
  private let resourceManager: ResourceManager
  
  public let onAddEditEvent: Signal<EditEvent, Never>
  internal let onAddEditEventObserver: Signal<EditEvent, Never>.Observer
  
  public let onUpdate: Signal<[EditEvent], Never>
  internal let onUpdateObserver: Signal<[EditEvent], Never>.Observer

  public let onError: Signal<Error, Never>
  internal let onErrorObserver: Signal<Error, Never>.Observer
  
  private var mutableEditEvents = MutableProperty<[EditEvent]>([])

  deinit {
  }

  public required init(
    resolver: FBSDKResolver,
    model: DataStore
  ) {
    let sortedModel: SortedModel = SortedModel(model: model)
    let selector = CKSelector()
    let choiceModel = ChoiceModel()
    let globalQueue = DispatchQueue.global(qos: .default)
    
    let modelManager: CKModelManager = CKModelManager(
      networkManager: resolver.get(),
      authManager: resolver.get(),
      eventManager: resolver.get(),
      stateManager: resolver.get(),
      resourceManager: resolver.get(),
      model: model,
      sortedModel: sortedModel,
      choiceModel: choiceModel,
      selector: selector,
      globalQueue: globalQueue
    )
    
    self.resolver = resolver
    self.stateManager = resolver.get()
    self.modelManager = modelManager
    self.resourceManager = resolver.get()
    self.appSession =  resolver.get()
    (self.onAddEditEvent, self.onAddEditEventObserver) = Signal<EditEvent, Never>.pipe()
    (self.onUpdate, self.onUpdateObserver) = Signal<[EditEvent], Never>.pipe()
    (self.onError, self.onErrorObserver) = Signal<Error, Never>.pipe()
    super.init()

    onUpdateObserver <~ stateManager.onUpdate.map { _ in [.normal] }
    onUpdateObserver <~ modelManager.onUpdate.map { _ in [.normal] }
    
    self.onAddEditEvent
      .collect(every: .seconds(3), on: QueueScheduler.main)
      .take(duringLifetimeOf: self)
      .observeValues { [weak self] editEvents in
        self?.consumeEditEventsForNetwork(editEvents: editEvents)
      }

    refreshData()
  }

  private func refreshData() {
    // update
    commitEditEvents()
  }

  private func refreshCurrentChapter() {}
  
  /// MARK - `Edit Events`

  private func consumeEditEvent(_ editEvent: EditEvent) {
    switch editEvent {
    case let .selectMessage(selectMessage):
      if let messageId = selectMessage.messageId {
        self.setSelected(.message(messageId))
      } else {
        self.setDeselected(.message)
      }
    case let .updateMessage(updateMessage):
      self.modelManager.updateMessage(
        messageId: updateMessage.messageId,
        text: updateMessage.text,
        displayIndex: updateMessage.displayIndex,
        active: updateMessage.active
      )
    case let .appendMessage(event):
      modelManager.appendNewMessage(
        previousMessageId: event.previousMessageId,
        selectedMessageId: event.selectedMessageId,
        nextMessageId: event.nextMessageId,
        textInput: event.text,
        characterId: event.characterId
      )
    case let .selectCharacter(event):
      if let characterId = event.characterId {
        modelManager.setSelected(.character(characterId))
      } else {
        modelManager.setDeselected(.character)
      }
    case .normal, .messageInputCommand, .characterControlBarCommand:
      break
    }
    self.onAddEditEventObserver.send(value: editEvent)
  }
  
  public func addEditEvent(_ editEvent: EditEvent) {
    mutableEditEvents.value.append(editEvent)
  }
  
  public func addAndCommitEditEvent(_ editEvent: EditEvent) {
    consumeEditEvent(editEvent)
    self.onUpdateObserver.send(value: [editEvent])
  }
  
  public func commitEditEvents(sessionId: String = normalEditSessionId, publishCommit: Bool = true) {
    if sessionId == normalEditSessionId {
      let editEvents = self.mutableEditEvents.value
      for editEvent in editEvents {
        consumeEditEvent(editEvent)
      }
      self.mutableEditEvents.value.removeAll()
      if publishCommit {
        self.onUpdateObserver.send(value: editEvents)
      }
    } else {
      let editEvents = self.mutableEditEvents.value.editEvents(sessionId: sessionId)
      for editEvent in editEvents {
        consumeEditEvent(editEvent)
      }
      self.mutableEditEvents.value = self.mutableEditEvents.value.editEvents(sessionId: sessionId, matching: false)
      if publishCommit {
        self.onUpdateObserver.send(value: editEvents)
      }
    }
  }
  
  private func consumeEditEventsForNetwork(editEvents: [EditEvent]) {
    var updateMessageEvents: [Int: EditEvent.UpdateMessageEvent] = [:]
    for editEvent in editEvents {
      switch editEvent {
      case let .updateMessage(event):
        let updateEvent = updateMessageEvents[event.messageId, default: event]
        updateMessageEvents[event.messageId] = EditEvent.UpdateMessageEvent(
          sessionId: event.sessionId,
          messageId: updateEvent.messageId,
          text: event.text ?? updateEvent.text,
          displayIndex: event.displayIndex ?? updateEvent.displayIndex,
          active: event.active ?? updateEvent.active
        )
      default:
        break
      }
    }
    for event in updateMessageEvents.values {
      self.resourceManager.updateMessage(
        messageId: event.messageId,
        text: event.text,
        displayIndex: event.displayIndex,
        active: event.active
      ).start()
    }
  }
  
  private func validateEditEvent(_ editEvent: EditEvent) -> Bool {
    switch editEvent {
    case let .selectMessage(event):
      if let messageId = event.messageId, self.selectedMessage?.messageId == messageId {
        return false
      }
    case let .messageInputCommand(event):
      switch event.command {
      case .becomeFirstResponder, .resignFirstResponder:
        break
      case let .setText(text):
        if self.selectedMessage?.text == text {
          return false
        }
      }
    default:
      break
    }
    return true
  }

  /// MARK - `DataStore`

  public func snapshot() -> DataStore { modelManager.getModel() }

  public func modifyDataStore(_ closure: @escaping (inout DataStore) -> Void) {
    modelManager.modifyDataStore(closure)
    commitEditEvents()
  }
}


extension WorkspaceManager: ChoiceGroupTableViewCellDelegate {
  public func choiceGroupTableViewCell(controlStateForChoice choiceId: Int, cell: ChoiceGroupTableViewCellProtocol) -> UIControl.State {
    Set(selectedChoices.map { $0.choiceId }).contains(choiceId) ? .highlighted : .normal
  }

  public func choiceRowView(choiceSelected choiceId: Int, cell: ChoiceRowViewProtocol) {
//    if modelManager.selectedChoiceIds.contains(choiceId) {
//      setDeselected(.choice(choiceId: choiceId))
//    } else {
//      // deselect all other choices in the same choice group
//      if let choiceGroup = model.fetchChoiceGroup(choiceGroupId: cell.choice.choiceGroupId) {
//        var choiceIds = Set(choiceGroup.choices.map { $0.choiceId })
//        choiceIds.remove(choiceId)
//        for choiceId in choiceIds {
//          setDeselected(.choice(choiceId: choiceId))
//        }
//      }
//      setDeselected(.message)
//      setSelected(.choice(choiceId: choiceId))
//    }
    commitEditEvents()
  }

  public func choiceRowView(textViewEditEvent event: UITextView.EditEvent, for choiceId: Int, cell: ChoiceRowViewProtocol) {
    switch event {
    case .onBegan:
      break
    case .onEnded:
      break
    case .onReturn:
      break
    }
  }
}
