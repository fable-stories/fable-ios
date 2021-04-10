//
//  StoryEditorSettingsViewController.swift
//  FableSDKViewControllers
//
//  Created by Andrew Aquino on 12/14/20.
//

import Foundation
import UIKit
import AsyncDisplayKit
import AppFoundation
import FableSDKResolver
import FableSDKEnums
import FableSDKViews
import FableSDKModelPresenters
import FableSDKModelObjects
import FableSDKModelManagers

public class StoryEditorSettingsViewController: ASDKViewController<StoryEditorSettingsNode> {
  
  private let resolver: FBSDKResolver
  private let eventManager: EventManager
  private let analyticsManager: AnalyticsManager
  private let modelPresenter: StoryDraftModelPresenter
  
  public init(resolver: FBSDKResolver, modelPresenter: StoryDraftModelPresenter) {
    self.resolver = resolver
    self.eventManager = resolver.get()
    self.analyticsManager = resolver.get()
    self.modelPresenter = modelPresenter
    super.init(node: .init())
    self.node.delegate = self
  }
  
  public required init?(coder: NSCoder) {
    fatalError()
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    self.eventManager.onEvent.sinkDisposed(receiveCompletion: nil) { [weak self] event in
      switch event {
      case StoryDraftModelPresenterEvent.didUpdateStory:
        self?.updateView()
      case StoryDraftModelPresenterEvent.didDeleteStory:
        self?.presentingViewController?.dismiss(animated: true, completion: nil)
      default:
        break
      }
    }
    
    self.updateView()
  }
  
  private func updateView() {
    if let model = modelPresenter.fetchModel() {
      self.node.setPublishState(model.fetchStory().isPublished)
    }
    self.node.reloadData()
  }
  
  private func presentStoryPreview() {
    guard let model = modelPresenter.fetchModel() else { return }
    let story = model.fetchStory()
    let chapter = model.currentChapter
    let datastore = DataStore(
      datastoreId: randomInt(),
      userId: story.userId,
      selectedChapterId: chapter.chapterId,
      story: story,
      categories: nil,
      chapters: [chapter].indexed(by: \.chapterId),
      messageGroups: nil,
      messages: model.fetchMessages().indexed(by: \.messageId),
      modifiers: nil,
      characters: model.fetchCharacters().indexed(by: \.characterId),
      choices: nil,
      choiceGroups: nil,
      colorHexStrings: model.colorHexString
    )
    self.eventManager.sendEvent(RouterRequestEvent.present(.storyReader(datastore: datastore), viewController: self))
  }
}

extension StoryEditorSettingsViewController: StoryEditorSettingsNodeDelegate {
  public func storyEditorSettingsNode(handleOption option: Option, node: StoryEditorSettingsNode) {
    switch option {
    case .showDetails:
      guard let navVC = self.navigationController else { return }
      self.analyticsManager.trackEvent(AnalyticsEvent.didTapDraftStoryDetails)
      self.eventManager.sendEvent(RouterRequestEvent.push(.storyEditorDetails(modelPresenter: modelPresenter), navigationController: navVC))
    case .previewStory:
      self.analyticsManager.trackEvent(AnalyticsEvent.didTapDraftStoryPreview)
      self.presentStoryPreview()
    case .publishStory:
      self.analyticsManager.trackEvent(AnalyticsEvent.didTapPublishStory)
      self.modelPresenter.updateStory(parameters: UpdateStoryParameters(isPublished: true))
    case .unpublishStory:
      self.analyticsManager.trackEvent(AnalyticsEvent.didTapUnublishStory)
      self.modelPresenter.updateStory(parameters: UpdateStoryParameters(isPublished: false))
    case .deleteStory:
      self.analyticsManager.trackEvent(AnalyticsEvent.didTapDeleteStory)
      let alert = UIAlertController(title: "Are you sure you want to delete this Story?", message: nil, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: nil))
      alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
        self?.modelPresenter.deleteStory().sinkDisposed(receiveCompletion: { [weak self] (completion) in
          switch completion {
          case let .failure(error):
            self?.presentAlert(error: error)
          case .finished:
            break
          }
        }, receiveValue: nil)
      }))
      self.present(alert, animated: true, completion: nil)
    }
  }
}
