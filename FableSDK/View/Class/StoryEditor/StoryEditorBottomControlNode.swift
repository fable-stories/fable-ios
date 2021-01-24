//
//  StoryEditorBottomControlNode.swift
//  FableSDKViews
//
//  Created by Andrew Aquino on 11/28/20.
//

import Foundation
import AsyncDisplayKit
import FableSDKUIFoundation
import FableSDKEnums

private let textInputFont = UIFont.systemFont(ofSize: 14.0, weight: .regular)

public protocol StoryEditorBottomControlNodeDelegate: class {
  func storyEditorBottomoControlNode(node: StoryEditorBottomControlNode, didTapSend text: String)
  func storyEditorBottomoControlNode(node: StoryEditorBottomControlNode, didTapUpdate messageId: Int, text: String)
}

public class StoryEditorBottomControlNode: ASDisplayNode {

  private var editMode: StoryDraftEditMode = .normal
  
  public var isDisabled: Bool = false {
    didSet {
      self.sendButtonNode.isDisabled = isDisabled
    }
  }

  private lazy var textViewNode: FBSDKTextViewNode = .new {
    let node = FBSDKTextViewNode(
      insets: .init(top: 8.0, left: 4.0, bottom: 0.0, right: 4.0),
      attributedPlaceholderText: "Tap here to start a new Message".toAttributedString(
        [
          .foregroundColor: UIColor.black.withAlphaComponent(0.4),
          .font: textInputFont
        ]
      )
    )
    ASPerformBlockOnMainThread {
      node.view.addBorder(.top, viewModel: FableBorderViewModel.regular)
      node.textView.returnKeyType = .done
      node.textView.delegate = self
    }
    return node
  }
  
  private lazy var sendButtonNode: FBSDKIconButtonNode = .new {
    let node = FBSDKIconButtonNode(primaryColor: UIColor("#1479FF"))
    node.addTarget(self, action: #selector(sendButtonTapped(button:)), forControlEvents: .touchUpInside)
    node.setImage(UIImage(named: "sendButtonBlue")?.withRenderingMode(.alwaysTemplate), for: .normal)
    node.imageNode.shadowColor = UIColor.black.cgColor
    node.imageNode.shadowOpacity = 0.25
    node.imageNode.shadowRadius = 2.0
    node.imageNode.shadowOffset = .init(width: 0.0, height: 2.0)
    node.imageNode.clipsToBounds = false
    return node
  }
  
  public weak var delegate: StoryEditorBottomControlNodeDelegate?
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  public override init() {
    super.init()
    self.automaticallyManagesSubnodes = true
  }
  
  public override func didLoad() {
    super.didLoad()
    self.backgroundColor = .white
    
    NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification(_:)), name: UIResponder.dismissFirstResponderNotification, object: nil)
  }
  
  public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    textViewNode.style.minHeight = .init(unit: .points, value: 40.0)
    textViewNode.style.width = .init(unit: .points, value: constrainedSize.max.width - 36.0 - 30.0)
    sendButtonNode.style.preferredSize = .sizeWithConstantDimensions(36.0)

    let contentSpec = ASStackLayoutSpec(
      direction: .horizontal,
      spacing: 10.0,
      justifyContent: .end,
      alignItems: .stretch,
      children: [
        textViewNode,
        sendButtonNode
      ]
    )

    return ASInsetLayoutSpec(
      insets: .insetWithConstantEdges(10.0),
      child: contentSpec
    )
  }
  
  @objc private func sendButtonTapped(button: FBSDKIconButtonNode) {
    button.isLoading = true
    self.delegate?.storyEditorBottomoControlNode(node: self, didTapSend: textViewNode.textView.text)
  }
  
  @objc private func didReceiveNotification(_ notification: Notification) {
    switch notification.name {
    case UIResponder.dismissFirstResponderNotification:
      self.textViewNode.resignFirstResponder()
    default:
      break
    }
  }
  
  public func setEditMode(_ editMode: StoryDraftEditMode) {
    self.editMode = editMode
  }
  
  public func resetTextInput() {
    self.textViewNode.textViewNode.attributedText = "".toAttributedString()
    self.textViewNode.style.height = .init(unit: .points, value: 40.0)
    self.setNeedsLayout()
    /// Invalidate height constraint after it has resetted
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      self.textViewNode.style.height = .init()
      self.textViewNode.validatePlaceholderState()
      self.setNeedsLayout()
      self.transitionLayout(withAnimation: false, shouldMeasureAsync: true, measurementCompletion: nil)
    }
  }
  
  public func setSendButtonLoadingIndicator(isHidden: Bool) {
    self.sendButtonNode.isLoading = !isHidden
  }
  
  @discardableResult
  public override func resignFirstResponder() -> Bool {
    return textViewNode.resignFirstResponder()
  }
}

extension StoryEditorBottomControlNode: UITextViewDelegate {
  public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if text == "\n" {
      self.resignFirstResponder()
    }
    return true
  }
}

public extension UIEdgeInsets {
  static func insetWithConstantEdges(_ constant: CGFloat) -> UIEdgeInsets {
    UIEdgeInsets(top: constant, left: constant, bottom: constant, right: constant)
  }
}

public extension CGSize {
  static func sizeWithConstantDimensions(_ constant: CGFloat) -> CGSize {
    CGSize(width: constant, height: constant)
  }
}

public class FBSDKTextViewNode: ASButtonNode {

  public let textViewNode: ASEditableTextNode
  
  private let insets: UIEdgeInsets

  public var textView: UITextView {
    textViewNode.textView
  }
  
  public var attributedPlaceholderText: NSAttributedString?
  
  public init(
    insets: UIEdgeInsets = .zero,
    attributedText: NSAttributedString? = nil,
    attributedPlaceholderText: NSAttributedString? = nil
  ) {
    self.insets = insets
    self.attributedPlaceholderText = attributedPlaceholderText
    let node = ASEditableTextNode()
    node.scrollEnabled = false
    node.attributedText = attributedText
    node.attributedPlaceholderText = attributedPlaceholderText
    self.textViewNode = node
    super.init()
    
    node.delegate = self
    ASPerformBlockOnMainThread {
      node.textView.autocorrectionType = .no
      node.textView.font = textInputFont
    }
    
    self.automaticallyManagesSubnodes = true
    self.addTarget(self, action: #selector(didTapSelf), forControlEvents: .touchUpInside)
  }
  
  public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    return ASInsetLayoutSpec(
      insets: insets,
      child: ASCenterLayoutSpec(
        centeringOptions: .Y,
        sizingOptions: .minimumY,
        child: textViewNode
      )
    )
  }
  
  public override func layoutDidFinish() {
    super.layoutDidFinish()
    self.textViewNode.style.width = .init(unit: .points, value: self.frame.width)
  }
  
  @discardableResult
  public override func becomeFirstResponder() -> Bool {
    return textViewNode.becomeFirstResponder()
  }
  
  @discardableResult
  public override func resignFirstResponder() -> Bool {
    return textViewNode.resignFirstResponder()
  }
  
  @objc private func didTapSelf() {
    self.becomeFirstResponder()
  }
  
  public func validatePlaceholderState() {
    let text = textView.text ?? ""
    self.textViewNode.attributedPlaceholderText = text.isEmpty ? attributedPlaceholderText : nil
  }
  
  public func setDelegate(_ delegate: ASEditableTextNodeDelegate) {
    self.textViewNode.delegate = delegate
  }
}

extension FBSDKTextViewNode: ASEditableTextNodeDelegate {
  public func editableTextNodeDidUpdateText(_ editableTextNode: ASEditableTextNode) {
    let text = editableTextNode.textView.text ?? ""
    ASPerformBlockOnMainThread {
      self.validatePlaceholderState()
      let height = text.boundingHeight(withConstrainedWidth: editableTextNode.frame.width, font: textInputFont)
      self.textViewNode.style.height = .init(unit: .points, value: height)
      self.setNeedsLayout()
    }
  }
}
