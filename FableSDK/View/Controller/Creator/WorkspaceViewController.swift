//
import AppFoundation
import AppUIFoundation
import FableSDKFoundation
import FableSDKResolver
import FableSDKModelObjects
import FableSDKModelManagers
import FableSDKUIFoundation
import FableSDKViewPresenters
import FableSDKViews
import Firebolt
import ReactiveCocoa
import ReactiveFoundation
import ReactiveSwift
import SnapKit
//  CKChapterViewController.swift
//  Fable
//
//  Created by Andrew Aquino on 9/12/19.
//
import UIKit

public enum WorkspaceEvent: EventContext {
  case deleteStoryEvent
}

public class WorkspaceViewController: UIViewController {

  private struct Section {
    public let indexPath: IndexPath
    public let message: Message
  }
  
  private let accessQueue: DispatchQueue

  private var sections: [Section] = []
  private var sectionsBySection: [Int: Section] = [:]
  private var sectionsByMessageId: [Int: Section] = [:]

  private let asyncQueue = AsyncOperationQueue(buffer: 1.0)

  private var indexPathMap: [Int: IndexPath] = [:]
  var isInView = false

  private let mutableOptions = MutableProperty<[OptionPickerViewController.Option]>([])

  private let resolver: FBSDKResolver
  private let workspaceManager: WorkspaceManager
  private let eventManager: EventManager
  private let stateManager: StateManager
  private let model: DataStore

  public init(
    resolver: FBSDKResolver,
    model: DataStore
  ) {
    self.resolver = resolver
    self.model = model
    self.workspaceManager = WorkspaceManager(resolver: resolver, model: model)
    self.eventManager = resolver.get()
    self.stateManager = resolver.get()
    self.accessQueue = DispatchQueue.global(qos: .default)
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  private let activityView = UIActivityIndicatorView(style: .medium)

  private let tableView = CKTableView(frame: .zero, style: .grouped).also {
    $0.register(MessageBlockTableViewCell.self, forCellReuseIdentifier: MessageBlockTableViewCell.reuseIdentifier)
    $0.register(ChoiceGroupTableViewCell.self, forCellReuseIdentifier: ChoiceGroupTableViewCell.reuseIdentifier)
  }

  private lazy var controlBar = CKControlBar()
  private var keyboardWhitespace = UIView.create {
    $0.backgroundColor = .fableWhite
  }

  private var controlBarBottomConstraint: Constraint!

  override public func viewDidLoad() {
    super.viewDidLoad()
    configureSelf()
    configureTableView()
    configureControlBar()
    configureLayout()
    configureReactive()
    configureReactiveDataModels()
    
    update()
  }
  
  override public func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.isInView = true
  }

  override public func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.isInView = false
  }
  
  // MARK: Configure Functions

  private func configureSelf() {
    view.backgroundColor = .white

    navigationItem.rightBarButtonItems = [
      UIBarButtonItem(image: UIImage(named: "menuIconBlack")) { [weak self] in
        self?.presentStoryOptions()
      },
      UIBarButtonItem(customView: activityView),
    ]

    UINavigationBar.setBottomBorderColor(.fableGray)

    self.workspaceManager.onError.take(duringLifetimeOf: self).observeValues { [weak self] error in
      self?.presentAlert(error: error)
    }
  }

  let button = UIButton.create {
    $0.setTitle("", for: .normal)
  }

  private func configureTableView() {
    tableView.dataSource = self
    tableView.delegate = self
    tableView.separatorColor = .clear
    tableView.backgroundColor = .clear
    tableView.estimatedRowHeight = MessageBlockTableViewCell.height
    tableView.rowHeight = UITableView.automaticDimension
    tableView.remembersLastFocusedIndexPath = true
    tableView.allowsSelectionDuringEditing = true
    tableView.contentInset = UIEdgeInsets(
      top: 0.0,
      left: 0.0,
      bottom: 16.0,
      right: 0.0
    )

    tableView.onBackgroundSelect = { [weak self] in
      guard let self = self else { return }
      let sessionId = randomUUIDString()
      /// deselect message
      self.workspaceManager.addEditEvent(.selectMessage(EditEvent.SelectMessageEvent(
        sessionId: sessionId,
        messageId: nil
      )))
      /// clear message input
      self.workspaceManager.addEditEvent(.messageInputCommand(EditEvent.MessageInputCommandEvent(
        sessionId: sessionId,
        command: .setText("")
      )))
      /// resign message input
      self.workspaceManager.addEditEvent(.messageInputCommand(EditEvent.MessageInputCommandEvent(
        sessionId: sessionId,
        command: .resignFirstResponder
      )))
      /// deselect character
      self.workspaceManager.addEditEvent(.characterControlBarCommand(.init(
        sessionId: sessionId,
        command: .selectCharacter(characterId: nil)
      )))
      self.workspaceManager.commitEditEvents(sessionId: sessionId)
    }
  }

  private func configureControlBar() {
    controlBar.onCharacterListSelect = { [weak self] in
      self?.presentCharacterList()
    }
    controlBar.onEditButtonSelect = { [weak self] in
      guard let self = self else { return }
      self.tableView.isEditing = !self.tableView.isEditing
    }
    controlBar.onChoiceBlockSelect = { [weak self] in
      guard let self = self else { return }
      self.workspaceManager.attachChoiceGroup()
    }
    controlBar.onSendSelect = { [weak self] textInput in
      guard let self = self else { return }
      /// gather existings state
      let selectedMessage = self.workspaceManager.selectedMessage
      let previousMessage: Message? = {
        if
          let selectedMessage = selectedMessage,
          let selectedSection = self.sectionsByMessageId[selectedMessage.messageId],
          let previousSection = self.sectionsBySection[selectedSection.indexPath.section - 1]
        {
          return previousSection.message
        }
        return self.sections.last?.message
      }()
      let nextMessage: Message? = {
        if
          let selectedMessage = selectedMessage,
          let selectedSection = self.sectionsByMessageId[selectedMessage.messageId],
          let nextsection = self.sectionsBySection[selectedSection.indexPath.section + 1]
        {
          return nextsection.message
        }
        return nil
      }()
      /// use existing text input if we're not currently selecting a message
      /// or clear the text input for new messages
      let textInput = selectedMessage  == nil ? textInput : ""
      /// deselect the given message and create a new message
      let sessionId = randomUUIDString()
      self.workspaceManager.addEditEvent(.selectMessage(EditEvent.SelectMessageEvent(
        sessionId: sessionId,
        messageId: nil
      )))
      /// clear the text input
      self.workspaceManager.addEditEvent(.messageInputCommand(EditEvent.MessageInputCommandEvent(
        sessionId: sessionId,
        command: .setText("")
      )))
      /// make text input active
      self.workspaceManager.addEditEvent(.messageInputCommand(.init(
        sessionId: sessionId,
        command: .becomeFirstResponder
      )))
      /// append new message
      self.workspaceManager.addEditEvent(.appendMessage(EditEvent.AppendMessageEvent(
        sessionId: sessionId,
        previousMessageId: previousMessage?.messageId,
        selectedMessageId: selectedMessage?.messageId,
        nextMessageId: nextMessage?.messageId,
        text: textInput,
        characterId: self.workspaceManager.selectedCharacter?.characterId,
        scrollToLastMessage: nextMessage == nil
      )))
      self.workspaceManager.commitEditEvents(sessionId: sessionId)
    }
  }

  private func configureLayout() {
    view.addSubview(tableView)
    view.addSubview(controlBar)
    view.addSubview(keyboardWhitespace)

    controlBar.snp.makeConstraints { make in
      controlBarBottomConstraint = make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).constraint
      make.leading.equalTo(view.snp.leading)
      make.trailing.equalTo(view.snp.trailing)
    }

    keyboardWhitespace.snp.makeConstraints { make in
      make.top.equalTo(controlBar.snp.bottom)
      make.bottom.equalTo(view.snp.bottom)
      make.leading.equalTo(view.snp.leading)
      make.trailing.equalTo(view.snp.trailing)
    }

    tableView.snp.makeConstraints { make in
      make.top.equalTo(view.snp.top)
      make.leading.equalTo(view.snp.leading)
      make.trailing.equalTo(view.snp.trailing)
      make.bottom.equalTo(controlBar.snp.top)
    }
  }

  private func configureReactive() {
    // Self

    updateTitle()
    updateOptions()

    // Keyboard Interaction

    NotificationCenter.default.reactive.keyboardChange
      .debounce(0.1, on: QueueScheduler.main)
      .take(duringLifetimeOf: self)
      .observeValues { [weak self] context in
        self?.asyncQueue.addOperation { [weak self] callback in
          guard let self = self, self.isInView else { return }
          DispatchQueue.main.async {
            let originY = context.endFrame.origin.y
            let height = context.endFrame.height
            let isKeyboardVisible = originY < ScreenSize.height
            self.controlBarBottomConstraint?.update(
              offset: isKeyboardVisible ? -(height - self.view.safeAreaInsets.bottom)
                : 0.0
            )
            UIView.animate(withDuration: 0.2, animations: {
              self.view.layoutIfNeeded()
            }) { _ in
              // scroll to selected message after keyaboard layout
              if
                let messageId = self.workspaceManager.selectedMessage?.messageId,
                let indexPath = self.indexPathMap[messageId] {
                self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
              }
              callback()
            }
          }
        }
      }
  }

  private func configureReactiveDataModels() {
    self.workspaceManager.onUpdate.take(duringLifetimeOf: self).observeValues { [weak self] editEvents in
      guard let self = self else { return }
      self.updateTitle()
      self.updateOptions()
      self.update()
      for editEvent in editEvents {
        switch editEvent {
        case let .appendMessage(event):
          if event.scrollToLastMessage {
            self.scrollToLastMessage()
          }
        default:
          break
        }
      }
    }
  }

  // MARK: View Functions

  private func updateTitle() {
    let title = self.workspaceManager.story.title
    let storyTitle = title.isEmpty ? "Fable Story" : title
    let titleAttributes = UINavigationBar.titleAttributes()
    let attrString = NSAttributedString(
      string: storyTitle,
      attributes: titleAttributes
    )
    navigationItem.titleView = UINavigationItem.makeTitleView(attrString)
  }

  private func updateOptions() {
    var options: [OptionPickerViewController.Option] = [
      OptionPickerViewController.Option(
        optionId: "story_details",
        attributedTitle: "Story Details".toAttributedString(.styled(.fableBlack, font: .fableFont(16.0, weight: .light)))
      ),
      OptionPickerViewController.Option(
        optionId: "remove_story",
        attributedTitle: "Delete Story".toAttributedString(.styled(.fableBlack, font: .fableFont(16.0, weight: .light)))
      ),
      OptionPickerViewController.Option(
        optionId: "preview_story",
        attributedTitle: "Preview Story".toAttributedString(.styled(.fableBlack, font: .fableFont(16.0, weight: .light)))
      ),
    ]
    if self.workspaceManager.story.isPublished {
      options.append(
        OptionPickerViewController.Option(
          optionId: "unpublish_story",
          attributedTitle: "Unpublish Story".toAttributedString(.styled(.fableBlack, font: .fableFont(16.0, weight: .light)))
        )
      )
    } else {
      options.append(
        OptionPickerViewController.Option(
          optionId: "publish_story",
          attributedTitle: "Publish Story".toAttributedString(.styled(.fableBlack, font: .fableFont(16.0, weight: .light)))
        )
      )
    }
    mutableOptions.value = options
  }

  private func update() {
    DispatchQueue.global(qos: .background).sync { [weak self] in
      guard let self = self else { return }
      let sections = self.workspaceManager.messages.enumerated().map { index, message in
        Section(indexPath: IndexPath(row: 0, section: index), message: message)
      }
      self.sectionsBySection.removeAll()
      self.sectionsByMessageId.removeAll()
      for section in sections {
        self.sectionsBySection[section.indexPath.section] = section
        self.sectionsByMessageId[section.message.messageId] = section
      }
      DispatchQueue.main.async {
        self.sections = sections
        self.tableView.reloadData()
      }
    }
  }

  private func scrollToSelectedMessage(messageId: Int) {
    guard let section = self.sections.first(where: { $0.message.messageId == messageId }) else { return }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      self.tableView.scrollToRow(at: section.indexPath, at: .middle, animated: true)
    }
  }
  
  private func scrollToLastMessage() {
    guard let indexPath = self.sections.last?.indexPath else { return }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
  }

  // MARK: Presenter Functions

  private func presentCharacterList() {
//    let vc = CharacterListViewController(workspaceManager: workspaceManager)
//    let navVC = UINavigationController(rootViewController: vc)
//    vc.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "closeButton")) { [weak vc] in
//      vc?.dismiss(animated: true, completion: nil)
//    }
//    present(navVC, animated: true, completion: nil)
  }

  private func presentStoryOptions() {
    let vc = OptionPickerViewController(OptionPickerViewController.Configuration(
      title: Property<String>(value: "Story Options"),
      initialSelectionIds: [],
      options: mutableOptions.map { $0 }
    ))
    vc.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backButton")) { [weak vc] in
      vc?.navigationController?.popViewController(animated: true)
    }
    vc.selectedOptions.signal.observeValues { [weak self] selectedOptions in
      if let option = selectedOptions.first {
        switch option.optionId {
        case "story_details":
          self?.presentStoryDetails()
        case "preview_story":
          self?.presentStoryPreview()
          self?.navigationController?.popViewController(animated: true)
        case "publish_story":
          self?.workspaceManager.publishStory()
          self?.presentingViewController?.dismiss(animated: true, completion: nil)
        case "unpublish_story":
          self?.workspaceManager.unpublishStory()
          self?.presentingViewController?.dismiss(animated: true, completion: nil)
        case "remove_story":
          self?.removeStory()
        default:
          break
        }
      }
    }
    navigationController?.pushViewController(vc, animated: true)
  }

  private func removeStory() {
    let alert = UIAlertController(title: nil, message: "Are you sure you want to delete this story?", preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
      self?.workspaceManager.removeStory()
      self?.eventManager.sendEvent(WorkspaceEvent.deleteStoryEvent)
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    present(alert, animated: true, completion: nil)
  }

  private func presentStoryDetails() {
//    let vc = StoryDetailsViewControllerV2(resolver: resolver, workspaceManager: workspaceManager)
//    navigationController?.pushViewController(vc, animated: true)
  }

  private func presentStoryPreview() {
    guard let vc = RKChapterViewController(resolver: resolver, model: self.workspaceManager.snapshot()) else { return }
    let navVC = UINavigationController(rootViewController: vc)
    navVC.modalPresentationStyle = .fullScreen
    vc.navigationItem.leftBarButtonItem = .makeCloseButton(onSelect: { [weak self] in
      self?.dismiss(animated: true, completion: nil)
    })
    present(navVC, animated: true, completion: nil)
  }
}

extension WorkspaceViewController: UITableViewDelegate, UITableViewDataSource {
  public func numberOfSections(in tableView: UITableView) -> Int {
    sections.count
  }

  public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    0.0
  }

  public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    nil
  }

  public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    0.0
  }

  public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    nil
  }

  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let section = sections[indexPath.section]
    let message = section.message

    // -- Choice Group Modifier --

    if message.choiceGroup != nil {
      let cell: ChoiceGroupTableViewCell = tableView.dequeueReusableCell(at: indexPath)
      cell.configure(message: message, delegate: workspaceManager)
      return cell
    }

    // -- No Modifier --

    let cell: MessageBlockTableViewCell = tableView.dequeueReusableCell(at: indexPath)

    indexPathMap[message.messageId] = indexPath

    // View Model

    let controlState: UIControl.State = self.workspaceManager.selectedMessage.flatMap {
      message.messageId == $0.messageId ? .focused : .normal
    } ?? .normal

    cell.configure(
      message: message,
      controlState: controlState,
      model: workspaceManager
    )

    return cell
  }

  public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//    guard presentedViewController == nil, isInView else { return }
//    let section = sections[indexPath.section]
//    let message = section.message
//    if let messageId = self.workspaceManager.selectedMessage?.messageId, messageId == message.messageId {
//      DispatchQueue.main.async {
//        cell.becomeFirstResponder()
//      }
//    }
  }

  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let section = sections[indexPath.section]
    let message = section.message
    
    let sessionId = randomUUIDString()

    if let selectedMessage = workspaceManager.selectedMessage, selectedMessage.messageId == message.messageId {
      /// select character from control bar if it exists in the message
      self.workspaceManager.addEditEvent(.characterControlBarCommand(.init(
        sessionId: sessionId,
        command: .selectCharacter(characterId: nil)
      )))
      self.workspaceManager.addEditEvent(.selectMessage(.init(
        sessionId: sessionId,
        messageId: nil
      )))
    } else {
      /// select character from control bar if it exists in the message
      if let characterId = message.characterId {
        self.workspaceManager.addEditEvent(.characterControlBarCommand(.init(
          sessionId: sessionId,
          command: .selectCharacter(characterId: characterId)
        )))
      }
      /// select message
      self.workspaceManager.addEditEvent( .selectMessage(.init(
        sessionId: sessionId,
        messageId: message.messageId
      )))
    }
    
    self.workspaceManager.commitEditEvents()
  }

  public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    true
  }

  public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let delete = UIContextualAction(
      style: .destructive,
      title: "Delete", handler: { [weak self] _, _, complete in
        guard let self = self else { return complete(false) }
        let messageId = self.sections[indexPath.section].message.messageId
        /// deselect message if removed message is the selected one
        if self.workspaceManager.selectedMessage?.messageId == messageId {
          self.workspaceManager.addEditEvent(.selectMessage(.init(messageId: nil)))
        }
        let prevMessage: Message? = {
          if indexPath.section > 0 {
            return self.sections[indexPath.section - 1].message
          }
          return nil
        }()
        self.workspaceManager.removeMessage(
          previousMessageId: prevMessage?.messageId,
          messageId: messageId
        )
        complete(true)
      }
    )
    delete.image = UIImage(named: "trashIcon")
    delete.backgroundColor = .fableWhite
    return UISwipeActionsConfiguration(actions: [delete])
  }

  public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    switch editingStyle {
    case .delete:
      let section = sections[indexPath.section]
      let messageId = section.message.messageId
      let prevMessage: Message? = {
        if indexPath.section > 0 {
          return self.sections[indexPath.section - 1].message
        }
        return nil
      }()
      self.workspaceManager.removeMessage(
        previousMessageId: prevMessage?.messageId,
        messageId: messageId
      )
    case .insert, .none: break
    @unknown default: break
    }
  }
  
  public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    return .none
  }
  
  public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
    return false
  }
  
  public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    guard
      let sourceSection = sectionsBySection[sourceIndexPath.section],
      let destSection = sectionsBySection[destinationIndexPath.section]
      else { return }
    let sessionId = randomUUIDString()
    workspaceManager.addEditEvent(.updateMessage(.init(
      sessionId: sessionId,
      messageId: sourceSection.message.messageId,
      displayIndex: destSection.message.displayIndex
    )))
    workspaceManager.addEditEvent(.updateMessage(.init(
      sessionId: sessionId,
      messageId: destSection.message.messageId,
      displayIndex: sourceSection.message.displayIndex
    )))
    self.workspaceManager.commitEditEvents(sessionId: sessionId, publishCommit: false)
  }

  private func reloadIndexPath(_ indexPath: IndexPath) {
    DispatchQueue.main.async {
      self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
  }
}
