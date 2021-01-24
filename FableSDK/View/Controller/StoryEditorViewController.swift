//
//  StoryEditorViewController.swift
//  FableSDKViewControllers
//
//  Created by Andrew Aquino on 11/28/20.
//

import Foundation
import AppFoundation
import FableSDKEnums
import AsyncDisplayKit
import FableSDKResolver
import FableSDKModelManagers
import FableSDKModelObjects
import FableSDKModelPresenters
import FableSDKViews

public class StoryEditorViewController: ASDKViewController<StoryEditorNode> {
  
  private let resolver: FBSDKResolver
  private let eventManager: EventManager
  private let messageManager: MessageManager
  private let characterManager: CharacterManager

  private let modelPresenter: StoryDraftModelPresenter
  private let initializedWithStoryId: Int?
  
  public init(resolver: FBSDKResolver, storyId: Int) {
    self.resolver = resolver
    self.eventManager = resolver.get()
    self.messageManager = resolver.get()
    self.characterManager = resolver.get()
    self.modelPresenter = StoryDraftModelPresenterBuilder.make(
      resolver: resolver
    )
    self.initializedWithStoryId = storyId
    super.init(node: .init())
  }
  
  public init(resolver: FBSDKResolver) {
    self.resolver = resolver
    self.eventManager = resolver.get()
    self.messageManager = resolver.get()
    self.characterManager = resolver.get()
    self.modelPresenter = StoryDraftModelPresenterBuilder.make(
      resolver: resolver
    )
    self.initializedWithStoryId = nil
    super.init(node: .init())
  }
  
  public required init?(coder: NSCoder) {
    fatalError()
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.rightBarButtonItem = .init(title: "More", style: .plain, target: self, action: #selector(didTapSettings))
                                                             
    self.node.setDelegate(self)
    self.configureReceivables()
    
    if let storyId = initializedWithStoryId {
      self.loadInitialData(storyId: storyId)
    } else {
      self.loadInitialDataAsNewStory()
    }
  }
  
  public func loadInitialDataAsNewStory() {
    self.navigationItem.rightBarButtonItem?.isEnabled = false
    self.node.setLoadingScreenHidden(false)
    self.modelPresenter.loadInitialDataAsNewStory()
  }

  public func loadInitialData(storyId: Int) {
    self.navigationItem.rightBarButtonItem?.isEnabled = false
    self.node.setLoadingScreenHidden(false)
    self.modelPresenter.loadInitialData(storyId: storyId)
  }
  
  private func configureReceivables() {
    self.eventManager.onEvent.sinkDisposed(receiveCompletion: nil) { [weak self] eventContext in
      guard let self = self else { return }
      guard let model = self.modelPresenter.fetchModel() else { return }
      
      switch eventContext {
      
      /// Editor Life Cycles
      
      case StoryDraftModelPresenterEvent.didLoadInitialData:
        self.title = model.fetchStory().title
        self.updateInitalView(model: model)
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.node.setLoadingScreenHidden(true)
        
      /// Messages
      
      case StoryDraftModelPresenterEvent.didInsertMessage(let messageId):
        guard let message = model.fetchMessage(messageId: messageId) else { return }
        self.node.insert(message: message)
      case StoryDraftModelPresenterEvent.didRemoveMessage(let messageId):
        self.node.remove(messageId: messageId)
      case let StoryDraftModelPresenterEvent.didSetCharacter(messageId, _):
        if let message = model.fetchMessage(messageId: messageId) {
          self.node.update(message: message)
        }
        
      /// Characters
      
      case StoryDraftModelPresenterEvent.didInsertCharacter:
        self.node.reloadCharacters(characters: model.fetchCharacters())
      case StoryDraftModelPresenterEvent.didRemoveCharacter:
        self.node.reloadCharacters(characters: model.fetchCharacters())
      case StoryDraftModelPresenterEvent.didUpdateCharacter:
        self.node.reloadMessages(messages: model.fetchMessages())

      /// Editor State
        
      case StoryDraftModelPresenterEvent.didSetEditMode(let editMode):
        switch editMode {
        case .normal:
          self.node.setSelectedCharacterId(nil)
          
        case .selectedMessage(let messageId):
          guard let message = model.fetchMessage(messageId: messageId) else { return }
          self.node.setSelectedCharacterId(message.characterId)
        }
        
      /// Misc
      
      case StoryDraftModelPresenterEvent.didReceiveError(let error):
        self.node.setSendButtonLoadingIndicator(isHidden: false)
        self.presentAlert(error: error)

      default:
        break
      }
    }
  }
  
  private func updateInitalView(model: StoryDraftModel) {
    /// Hydrate messages
    self.node.updateInitalView(messages: model.fetchMessages(), characters: model.fetchCharacters())
  }
  
  @objc private func didTapSettings() {
    let vc = StoryEditorSettingsViewController(resolver: resolver, modelPresenter: modelPresenter)
    vc.navigationItem.leftBarButtonItem = .makeBackButton(onSelect: { [weak self] in
      self?.navigationController?.popViewController(animated: true)
    })
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

extension StoryEditorViewController: StoryEditorNodeDelegate {
  public func storyEditorNode(requestToCreateMessage text: String, previousMessageId: Int?, nextMessageId: Int?, selectedCharacterId: Int?) {
    self.modelPresenter.insertMessage(
      text: text,
      previousMessageId: previousMessageId,
      nextMessageId: nextMessageId,
      selectedCharacterId: selectedCharacterId
    )
  }
  
  public func storyEditorNode(requestToDeleteMessage messageId: Int) {
    self.modelPresenter.removeMessage(messageId: messageId)
  }
  
  public func storyEditorNode(requestToUpdateMessage messageId: Int, text: String?, displayIndex: Int?) {
    self.modelPresenter.updateMessage(
      messageId: messageId,
      text: text,
      displayIndex: displayIndex
    )
  }
  
  public func storyEditorNode(requestToSelectMessage messageId: Int) {
    self.modelPresenter.setEditMode(.selectedMessage(messageId: messageId))
  }

  public func storyEditorNode(requestToDeselectMessage messageId: Int) {
    self.modelPresenter.setEditMode(.normal)
  }

  public func storyEditorNode(showCharacterList node: StoryEditorNode) {
    let vc = CharacterListViewController(
      resolver: resolver,
      storyDraftModelPresenter: modelPresenter
    )
    vc.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "closeButton")) { [weak vc] in
      vc?.dismiss(animated: true, completion: { [weak self] in
        guard let model = self?.modelPresenter.fetchModel() else { return }
        self?.node.reloadCharacters(characters: model.fetchCharacters())
        self?.node.reloadMessages(messages: model.fetchMessages())
      })
    }
    let navVC = UINavigationController(rootViewController: vc)
    navVC.modalPresentationStyle = .overFullScreen
    self.present(navVC, animated: true, completion: nil)
  }
  
  public func storyEditorNode(selectedCharacter characterId: Int, selectedMessageId: Int?, node: StoryEditorNode) {
    /// Attach Character to selected Message
    if let selectedMessageId = selectedMessageId {
      self.modelPresenter.setCharacterForMessage(messageId: selectedMessageId, characterId: characterId)
    }
  }
  
  public func storyEditorNode(deselectedCharacter characterId: Int, selectedMessageId: Int?, node: StoryEditorNode) {
    /// Detach Character from selected Message
    if let selectedMessageId = selectedMessageId {
      self.modelPresenter.setCharacterForMessage(messageId: selectedMessageId, characterId: nil)
    }
  }
}
