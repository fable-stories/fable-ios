//
//  StoryEditorNode.swift
//  FableSDKViews
//
//  Created by Andrew Aquino on 11/28/20.
//

import Foundation
import AppFoundation
import AppUIFoundation
import AsyncDisplayKit
import FableSDKEnums
import FableSDKUIFoundation
import FableSDKModelObjects
import Lottie

private let newMessageId = -1
private let tableNodeTapGestureName = "tableNodeTapGesture"

public protocol StoryEditorMessage {
  var messageId: Int { get }
  var text: String { get }
  var messageAlignment: MessageAlignment { get }
  var displayIndex: Int { get }
  var character: Character? { get }
}

public class DefaultStoryEditorMessage: StoryEditorMessage {
  public let messageId: Int
  public var text: String
  public var messageAlignment: MessageAlignment
  public var displayIndex: Int
  public var character: Character?

  public init(message: Message) {
    self.messageId = message.messageId
    self.text = message.text
    self.messageAlignment = message.character?.messageAlignment ?? .center
    self.displayIndex = message.displayIndex
    self.character = message.character
  }
}

public protocol StoryEditorNodeDelegate: class {
  /// Messages
  func storyEditorNode(requestToCreateMessage text: String, previousMessageId: Int?, nextMessageId: Int?, selectedCharacterId: Int?)
  func storyEditorNode(requestToDeleteMessage messageId: Int)
  func storyEditorNode(requestToUpdateMessage messageId: Int, text: String?, displayIndex: Int?)
  func storyEditorNode(requestToSelectMessage messageId: Int)
  func storyEditorNode(requestToDeselectMessage messageId: Int)
  /// Characters
  func storyEditorNode(showCharacterList node: StoryEditorNode)
  func storyEditorNode(selectedCharacter characterId: Int, selectedMessageId: Int?, node: StoryEditorNode)
  func storyEditorNode(deselectedCharacter characterId: Int, selectedMessageId: Int?, node: StoryEditorNode)
}

public class StoryEditorNode: ASDisplayNode {
  
  private var keyboardIsHidden = true
  private var keyboardSize: CGRect = .zero
  private var isLoadingScreenHidden: Bool = false
  
  private weak var delegate: StoryEditorNodeDelegate?
  
  private var messages: [StoryEditorMessage] = []
  private var messageById: [Int: StoryEditorMessage] = [:]
  private var indexPathByMessageId: [Int: IndexPath] = [:]
  private var selectedMessageId: Int?

  private lazy var containerNode: AccomodationKeyboardNode = .new {
    let node = AccomodationKeyboardNode()
    return node
  }

  private lazy var tableNode: FBSDKTableNode = .new {
    let node = FBSDKTableNode(style: .plain)
    node.delegate = self
    node.dataSource = self
    node.view.separatorColor = .clear
    node.allowsSelectionDuringEditing = false
    node.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 24.0, right: 0.0)
    return node
  }
  
  private lazy var characterControlNode: CharacterControlNode = .new {
    let node = CharacterControlNode()
    node.delegate = self
    return node
  }
 
  private lazy var bottomControlNode: StoryEditorBottomControlNode = .new {
    let node = StoryEditorBottomControlNode()
    node.delegate = self
    return node
  }
  
  public override init() {
    super.init()
    self.automaticallyManagesSubnodes = true
    self.automaticallyRelayoutOnSafeAreaChanges = true
    self.backgroundColor = .white

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(didReceiveNotification(_:)),
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(didReceiveNotification(_:)),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
    
    let tableNodeTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTableNodeBackground))
    tableNodeTapGesture.cancelsTouchesInView = false
    tableNodeTapGesture.delegate = self
    tableNodeTapGesture.name = tableNodeTapGestureName
    tableNode.view.addGestureRecognizer(tableNodeTapGesture)
  }
  
  public override func didLoad() {
    super.didLoad()
  }

  public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    self.characterControlNode.style.width = .init(unit: .points, value: constrainedSize.max.width)
    self.characterControlNode.style.minHeight = .init(unit: .points, value: 46.0)
    self.bottomControlNode.style.width = .init(unit: .points, value: constrainedSize.max.width)
    self.bottomControlNode.style.minHeight = .init(unit: .points, value: 56.0)

    let contentSpec = ASStackLayoutSpec(
      direction: .vertical,
      spacing: 0.0,
      justifyContent: .center,
      alignItems: .start,
      children: [
        tableNode.flexGrow(),
        characterControlNode,
        bottomControlNode
      ]
    )

    return ASInsetLayoutSpec(
      insets: .init(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0),
      child: contentSpec
    )
  }
  
  public func updateInitalView(messages: [Message], characters: [Character]) {
    /// -- Messages --
    self.reloadMessages(messages: messages)
    /// -- Characters --
    self.reloadCharacters(characters: characters)
  }
  
  public func insert(message: Message) {
    let message = DefaultStoryEditorMessage(message: message)
    self.messages.append(message)
    self.bottomControlNode.setSendButtonLoadingIndicator(isHidden: true)
    self.tableNode.reloadData { [weak self] in
      guard let self = self else { return }
      self.scrollToBottom()
    }
  }
  
  public func remove(messageId: Int) {
    if let index = self.messages.firstIndex(where: { $0.messageId == messageId }) {
      self.messages.remove(at: index)
      self.tableNode.reloadData()
    }
  }
  
  public func update(message: Message) {
    if let index = self.messages.firstIndex(where: { $0.messageId == message.messageId }) {
      let message = DefaultStoryEditorMessage(message: message)
      self.messages[index] = message
      self.reloadMessages(messageIds: [message.messageId])
    }
  }

  public func reloadMessages(messages: [Message]) {
    let messages: [StoryEditorMessage] = messages
      .map { DefaultStoryEditorMessage(message: $0) }
    self.messages = messages
    self.tableNode.reloadData()
  }
  
  public func reloadMessages(messageIds: Set<Int>) {
    let indexPaths = messageIds.compactMap { indexPathByMessageId[$0] }
    self.tableNode.reloadRows(at: indexPaths, with: .none)
  }

  public func reloadCharacters(characters: [Character]) {
    self.characterControlNode.setCharacters(characters: characters)
  }

  @objc private func didReceiveNotification(_ notification: Notification) {
    switch notification.name {
    case UIResponder.keyboardWillShowNotification:
      if let keyboardSize = notification.userInfo?.keyboardSize {
        self.setKeyboardContext(keyboardSize, isHidden: false)
      }
    case UIResponder.keyboardWillHideNotification:
      if let keyboardSize = notification.userInfo?.keyboardSize {
        self.setKeyboardContext(keyboardSize, isHidden: true)
      }
    default:
      break
    }
  }
  
  @objc private func didTapTableNodeBackground() {
    self.setSelectedCharacterId(nil)
    NotificationCenter.default.post(name: StoryEditorNotificationName.didSelectCharacter.name, object: nil)
    NotificationCenter.default.post(name: UIResponder.dismissFirstResponderNotification, object: nil)
  }
  
  private func setKeyboardContext(_ keyboardSize: CGRect, isHidden: Bool) {
    if self.keyboardIsHidden == isHidden { return }
    self.keyboardSize = isHidden ? .zero : keyboardSize
    self.keyboardIsHidden = isHidden
    ASPerformBlockOnMainThread {
      self.transitionLayout(withAnimation: false, shouldMeasureAsync: true) { [weak self] in
        DispatchQueue.main.async {
          self?.scrollToBottom()
        }
      }
    }
  }
  
  public func setDelegate(_ delegate: StoryEditorNodeDelegate) {
    self.delegate = delegate
  }
  
  public func setEditMode(_ editMode: StoryDraftEditMode) {
    self.bottomControlNode.setEditMode(editMode)
  }
  
  public func setSelectedCharacterId(_ characterId: Int?) {
    self.characterControlNode.setSelectedCharacter(characterId: characterId)
  }
  
  public func setLoadingScreenHidden(_ isHidden: Bool) {
    self.characterControlNode.isDisabled = !isHidden
    self.bottomControlNode.isDisabled = !isHidden
    if isHidden {
      self.tableNode.stopLoadingAnimation()
    } else {
      self.tableNode.playLoadingAnimation()
    }
  }
  
  public func setSendButtonLoadingIndicator(isHidden: Bool) {
    self.bottomControlNode.setSendButtonLoadingIndicator(isHidden: isHidden)
  }
  
  private func scrollToBottom() {
    self.tableNode.scrollToRow(
      at: IndexPath(row: self.messages.count - 1, section: 0),
      at: .bottom,
      animated: true
    )
  }
}

extension StoryEditorNode: UIGestureRecognizerDelegate {
  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    switch gestureRecognizer.name {
    case tableNodeTapGestureName:
      return touch.view === tableNode.view
    default: break
    }
    return false
  }
}

extension StoryEditorNode: ASTableDelegate, ASTableDataSource {
  public func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    return self.messages.count
  }

  public func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
    let message = self.messages[indexPath.row]
    let minimumCellSize = CGSize(width: view.frame.width, height: 44.0)
    
    self.indexPathByMessageId[message.messageId] = indexPath
    
    switch message {
    case let message as DefaultStoryEditorMessage:
      return {
        let node = MessageCellNode(minimumCellSize: minimumCellSize,  message: message)
        node.delegate = self
        return node
      }
    default:
      return {
        let node = ASCellNode()
        return node
      }
    }
  }

  public func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
    if let cell = tableNode.nodeForRow(at: indexPath) as? MessageCellNode {
      
      /// deselect
      if let selectedMessageId = selectedMessageId, cell.message.messageId == selectedMessageId {
        cell.resignFirstResponder()
      }
      
      /// select
      else {
        cell.becomeFirstResponder()
        
        DispatchQueue.main.async {
          tableNode.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
      }
    }
  }

  public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let message = self.messages[indexPath.row]
    return .init(actions: [
      .init(style: .destructive, title: "Delete", handler: { [weak self] (action, view, callback) in
        self?.delegate?.storyEditorNode(requestToDeleteMessage: message.messageId)
        callback(true)
      })
    ])
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
    let sourceRow = sourceIndexPath.row
    let destRow = destinationIndexPath.row
    
    guard
      let sourceMessage = self.messages[sourceRow] as? DefaultStoryEditorMessage,
      let destMessage = self.messages[destRow] as? DefaultStoryEditorMessage
      else { return }
    
    let sourceDisplayIndex = sourceMessage.displayIndex
    let destDisplayIndex = destMessage.displayIndex
    
    /// Move was adjacent so we're just swapping
    if sourceRow + 1 == destRow || sourceRow - 1 == destRow {
      
      sourceMessage.displayIndex = destDisplayIndex
      destMessage.displayIndex = sourceDisplayIndex
      
      self.messages[destRow] = sourceMessage
      self.messages[sourceRow] = destMessage

      self.delegate?.storyEditorNode(
        requestToUpdateMessage: sourceMessage.messageId,
        text: nil,
        displayIndex: destDisplayIndex
      )

      self.delegate?.storyEditorNode(
        requestToUpdateMessage: destMessage.messageId,
        text: nil,
        displayIndex: sourceDisplayIndex
      )
    }
    
    /// Move was towards the top, destination message moves under
    else if sourceRow > destRow {
      /// Source goes in between before Destination Before and Destination
      let beforeMessage: DefaultStoryEditorMessage? = {
        if destRow - 1 >= 0 {
          return self.messages[destRow - 1] as? DefaultStoryEditorMessage
        }
        return nil
      }()
      
      let displayIndex: Int = {
        if let beforeMessage = beforeMessage {
          return (beforeMessage.displayIndex + destMessage.displayIndex) / 2
        }
        return destMessage.displayIndex / 2
      }()
      
      sourceMessage.displayIndex = displayIndex
      self.messages[sourceRow] = sourceMessage
      self.messages.sort(by: { $0.displayIndex < $1.displayIndex })

      self.delegate?.storyEditorNode(
        requestToUpdateMessage: sourceMessage.messageId,
        text: nil,
        displayIndex: displayIndex
      )
    }
    
    /// Move was towards the bottom, destination message moves up
    else if sourceRow < destRow {
      /// Source goes in between Desination and Destination Next
      let nextMessage: DefaultStoryEditorMessage? = {
        if destRow + 1 < self.messages.count {
          return self.messages[destRow + 1] as? DefaultStoryEditorMessage
        }
        return nil
      }()
      
      let displayIndex: Int = {
        if let nextMessage = nextMessage {
          return (destMessage.displayIndex + nextMessage.displayIndex) / 2
        }
        return destMessage.displayIndex + 100000
      }()
      
      sourceMessage.displayIndex = displayIndex
      self.messages[sourceRow] = sourceMessage
      self.messages.sort(by: { $0.displayIndex < $1.displayIndex })
      
      self.delegate?.storyEditorNode(
        requestToUpdateMessage: sourceMessage.messageId,
        text: nil,
        displayIndex: displayIndex
      )
    }
  }
}

extension StoryEditorNode: MessageCellNodeDelegate {
  public func messageCellNode(textViewDidChange textView: UITextView, node: MessageCellNode) {
  }
  
  public func messageCellNode(textViewDidReturn textView: UITextView, node: MessageCellNode) {
    if let indexPath = node.indexPath {
      self.delegate?.storyEditorNode(
        requestToUpdateMessage: node.message.messageId,
        text: node.message.text,
        displayIndex: nil
      )
      self.tableNode.reloadRows(at: [indexPath], with: .none)
    }
  }
  
  public func messageCellNode(textViewDidBeginEditing textView: UITextView, node: MessageCellNode) {
    /// Make sure the caret starts at the correct position
    let newPosition = textView.endOfDocument
    textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)

    /// select
    self.selectedMessageId = node.message.messageId
    self.delegate?.storyEditorNode(requestToSelectMessage: node.message.messageId)
  }
  
  public func messageCellNode(textViewDidEndEditing textView: UITextView, node: MessageCellNode) {
    /// deselect
    if let selectedMessageId = selectedMessageId, selectedMessageId == node.message.messageId {
      self.selectedMessageId = nil
      self.delegate?.storyEditorNode(requestToDeselectMessage: selectedMessageId)
    }
    
    switch node.message {
    case let message as DefaultStoryEditorMessage:
      if node.message.text != textView.text {
        message.text = textView.text
        self.reloadMessages(messageIds: [node.message.messageId])
        self.delegate?.storyEditorNode(
          requestToUpdateMessage: node.message.messageId,
          text: textView.text,
          displayIndex: nil
        )
      }
    default:
      break
    }
  }
}

extension StoryEditorNode: StoryEditorBottomControlNodeDelegate {
  public func storyEditorBottomoControlNode(node: StoryEditorBottomControlNode, didTapSend text: String) {
    node.resetTextInput()
    /// For now we're just appending to the last message
    self.delegate?.storyEditorNode(
      requestToCreateMessage: text,
      previousMessageId: self.messages.last?.messageId,
      nextMessageId: nil,
      selectedCharacterId: self.characterControlNode.selectedCharacterId
    )
  }
  
  public func storyEditorBottomoControlNode(node: StoryEditorBottomControlNode, didTapUpdate messageId: Int, text: String) {
    self.delegate?.storyEditorNode(
      requestToUpdateMessage: messageId,
      text: text,
      displayIndex: nil
    )
  }
}

extension StoryEditorNode: CharacterControlNodeDelegate {
  public func characterControlNode(showCharacterList node: CharacterControlNode) {
    self.delegate?.storyEditorNode(showCharacterList: self)
  }
  
  public func characterControlNode(showMoreOptions node: CharacterControlNode) {
    UIView.performWithoutAnimation {
      self.tableNode.view.isEditing = !self.tableNode.view.isEditing
    }
  }
  
  public func characterControlNode(selectedCharacter characterId: Int) {
    self.delegate?.storyEditorNode(selectedCharacter: characterId, selectedMessageId: selectedMessageId, node: self)
  }
  
  public func characterControlNode(deselectedCharacter characterId: Int) {
    self.delegate?.storyEditorNode(deselectedCharacter: characterId, selectedMessageId: selectedMessageId, node: self)
  }
}

public protocol MessageCellNodeDelegate: class {
  func messageCellNode(textViewDidChange textView: UITextView, node: MessageCellNode)
  func messageCellNode(textViewDidReturn textView: UITextView, node: MessageCellNode)
  func messageCellNode(textViewDidBeginEditing textView: UITextView, node: MessageCellNode)
  func messageCellNode(textViewDidEndEditing textView: UITextView, node: MessageCellNode)
}

public class MessageCellNode: ASCellNode {
  private let defaultMessageFont: UIFont = .systemFont(ofSize: 14.0, weight: .regular)
  private let defaultCharacterFont : UIFont = .systemFont(ofSize: 12.0, weight: .semibold)
  
  private lazy var contentInset = UIEdgeInsets(
    top: 12.0,
    left: 24.0 + (message.messageAlignment == .leading ? -12.0 : 0.0),
    bottom: 0.0,
    right: 24.0 + (message.messageAlignment == .trailing ? -12.0 : 0.0)
  )

  private let minimumCellSize: CGSize
  public let message: StoryEditorMessage

  public weak var delegate: MessageCellNodeDelegate?
  
  private lazy var containerInset = UIEdgeInsets(top: 8.0, left: 14.0, bottom: 12.0, right: 14.0)

  private lazy var container: ASDisplayNode = .new {
    let node = ASDisplayNode()
    node.automaticallyManagesSubnodes = true
    
    node.backgroundColor = message.character?.color ?? .white

    node.shadowColor = UIColor.black.cgColor
    node.shadowOpacity = 0.1
    node.shadowRadius = 4.0
    node.shadowOffset = .init(width: 0.0, height: 4.0)
    node.clipsToBounds = false

    ASPerformBlockOnMainThread {
      if self.message.character?.color == nil {
        node.borderWidth = 1.0
        node.borderColor = UIColor.lightGray.cgColor
      }
      node.layer.cornerRadius = 44.0 / 2.0
    }
    return node
  }
  
  private lazy var characterTextNode: ASTextNode = .new {
    let node = ASTextNode()
    node.attributedText = message.character?.name.toAttributedString([
      .foregroundColor: UIColor.white,
      .font: self.defaultCharacterFont
    ])
    return node
  }
  
  private lazy var textViewNode: FBSDKTextViewNode = .new {
    let node = FBSDKTextViewNode(
      insets: .zero,
      attributedText: self.message.text.toAttributedString(
        [
          .foregroundColor: self.message.character?.color == nil ? UIColor.black : UIColor.white,
          .font: self.defaultMessageFont
        ]
      ),
      attributedPlaceholderText: "Tap here to update Message".toAttributedString(
        [
          .foregroundColor: UIColor.black.withAlphaComponent(0.4),
          .font: self.defaultMessageFont
        ]
      )
    )
    ASPerformBlockOnMainThread {
      node.textView.isScrollEnabled = false
      node.textView.font = self.defaultMessageFont
      node.textView.autocorrectionType = .no
      node.textView.delegate = self
      node.textView.returnKeyType = .done
    }
    return node
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  public init(minimumCellSize: CGSize, message: StoryEditorMessage) {
    self.minimumCellSize = minimumCellSize
    self.message = message
    super.init()
    self.automaticallyManagesSubnodes = true
    self.selectionStyle = .none
    self.clipsToBounds = false

    self.style.minSize = minimumCellSize
      .reverseInset(by: UIEdgeInsets(top: 12.0, left: 0.0, bottom: 0.0, right: 0.0))
    let containerMinSize = minimumCellSize.inset(by: contentInset)
    self.container.style.minSize = containerMinSize

    NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification(_:)), name: UIResponder.dismissFirstResponderNotification, object: nil)
  }

  public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let isCharacterEnabled = self.message.character != nil
    
    let containerInset = self.containerInset
    let textViewNode = self.textViewNode
    let characterTextNode = self.characterTextNode

    self.container.layoutSpecBlock = { node, _ in
      return ASInsetLayoutSpec(
        insets: containerInset,
        child: ASStackLayoutSpec(
          direction: .vertical,
          spacing: 3.0,
          justifyContent: .center,
          alignItems: .stretch,
          children: [
            isCharacterEnabled ? characterTextNode : nil,
            textViewNode
          ].compactMap { $0 }
        )
      )
    }

    let containerSpec = ASInsetLayoutSpec(
      insets: contentInset,
      child: container
    )
    
    return containerSpec
  }
  
  public override func layout() {
    super.layout()
  }
  
  @objc private func didReceiveNotification(_ notification: Notification) {
    switch notification.name {
    case UIResponder.dismissFirstResponderNotification:
      self.resignFirstResponder()
    default:
      break
    }
  }
  
  @discardableResult
  public override func becomeFirstResponder() -> Bool {
    return self.textViewNode.becomeFirstResponder()
  }
  
  @discardableResult
  public override func resignFirstResponder() -> Bool {
    return self.textViewNode.resignFirstResponder()
  }
  
  public func setSelected(_ isSelected: Bool) {
    self.container.borderColor = (isSelected ? UIColor.black : UIColor.lightGray).cgColor
  }
}

extension MessageCellNode: UITextViewDelegate {
  public func textViewDidChange(_ textView: UITextView) {
    self.textViewNode.validatePlaceholderState()

    self.delegate?.messageCellNode(textViewDidChange: textView, node: self)
  }
  
  public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if text == "\n" {
      self.delegate?.messageCellNode(textViewDidReturn: textView, node: self)
    }
    return true
  }
  
  public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
    return true
  }
  
  public func textViewDidBeginEditing(_ textView: UITextView) {
    self.setSelected(true)
    self.delegate?.messageCellNode(textViewDidBeginEditing: textView, node: self)
  }
  
  public func textViewDidEndEditing(_ textView: UITextView) {
    self.setSelected(false)
    self.delegate?.messageCellNode(textViewDidEndEditing: textView, node: self)
  }
}

public class TextViewNode: ASEditableTextNode {
}

public class InsetNode: ASDisplayNode {
  
  private let insets: UIEdgeInsets
  public var child: ASDisplayNode {
    didSet {
      self.setNeedsLayout()
    }
  }
  
  public init(insets: UIEdgeInsets, child: ASDisplayNode = ASDisplayNode()) {
    self.insets = insets
    self.child = child
    super.init()
    self.automaticallyManagesSubnodes = true
  }
  
  public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    return ASInsetLayoutSpec(
      insets: insets,
      child: ASCenterLayoutSpec(
        centeringOptions: .Y,
        sizingOptions: .minimumY,
        child: child
      )
    )
  }
}

public extension ASLayoutElement {
  @discardableResult
  func flexShrink() -> Self {
    self.style.flexShrink = 1
    return self
  }
  @discardableResult
  func flexGrow() -> Self {
    self.style.flexGrow = 1
    return self
  }
}

public extension ASStackLayoutSpec {
  @discardableResult
  func flexWrap(_ flexWrap: ASStackLayoutFlexWrap) -> Self {
    self.flexWrap = flexWrap
    return self
  }
}

public class VerticallyCenteredTextView: PlaceholderTextView {
  public override var contentSize: CGSize {
    didSet {
      var topCorrection = (bounds.size.height - contentSize.height * zoomScale) / 2.0
      topCorrection = max(0, topCorrection)
      contentInset = UIEdgeInsets(top: topCorrection, left: 0, bottom: 0, right: 0)
    }
  }
}

public extension UITextView {
  func heightForText(withConstrainedWidth width: CGFloat) -> CGFloat {
    let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
    let boundingBox = text.boundingRect(
      with: constraintRect,
      options: .usesLineFragmentOrigin,
      attributes: [.font: font ?? UIFont.systemFont(ofSize: 12.0, weight: .regular)],
      context: nil
    )
    return ceil(boundingBox.height)
  }
  
  func widthForText(withConstrainedHeight height: CGFloat) -> CGFloat {
    let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
    let boundingBox = text.boundingRect(
      with: constraintRect,
      options: .usesLineFragmentOrigin,
      attributes: [.font: font ?? UIFont.systemFont(ofSize: 12.0, weight: .regular)],
      context: nil
    )
    return ceil(boundingBox.width)
  }
}

public extension String {
  func boundingHeight(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
    let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
    let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
    return ceil(boundingBox.height)
  }
  
  func boundingWidth(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
    let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
    let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
    return ceil(boundingBox.width)
  }
}

public extension UIResponder {
  static let dismissFirstResponderNotification = Notification.Name(
    rawValue: "UIResponder.dismissFirstResponderNotification"
  )
}

private extension Dictionary where Key == AnyHashable, Value == Any {
  var keyboardSize: CGRect? {
    (self[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
  }
}

public class AccomodationKeyboardNode: ASDisplayNode {
  
  public var layoutSpecThatFitsBlock: ((_ constrainedSize: ASSizeRange) -> ASLayoutSpec)?

  public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    self.layoutSpecThatFitsBlock?(constrainedSize) ?? ASWrapperLayoutSpec(layoutElement: ASDisplayNode())
  }
}

public class FBSDKTableNode: ASTableNode {
  private var animationView: AnimationView?
  
  public override func layoutDidFinish() {
    super.layoutDidFinish()
    if self.view.backgroundView == nil {
      let animationView = self.getAnimationView()
      animationView.frame.size = .sizeWithConstantDimensions(self.bounds.size.width / 4.0)
      animationView.center = self.view.center
      let containerView = UIView()
      containerView.addSubview(animationView)
      self.view.backgroundView = containerView
      self.view.backgroundView?.isUserInteractionEnabled = false
    }
  }
  
  private func getAnimationView() -> AnimationView {
    if let animationView = self.animationView {
      return animationView
    }
    let animationView = AnimationView(name: "loading_indicator")
    animationView.loopMode = .loop
    animationView.contentMode = .scaleAspectFit
    animationView.isUserInteractionEnabled = false
    self.animationView = animationView
    return animationView
  }
  
  public func playLoadingAnimation() {
    let animationView = getAnimationView()
    animationView.play()
  }
  
  public func stopLoadingAnimation() {
    let animationView = getAnimationView()
    animationView.stop()
  }
}
