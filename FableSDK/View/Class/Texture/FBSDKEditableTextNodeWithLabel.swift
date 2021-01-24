//
//  FBASEditableTextNode.swift
//
//  Created by Madan U S on 17/11/20.
//

import Foundation
import FableSDKUIFoundation
import AsyncDisplayKit

public class FBSDKEditableTextNodeWithLabel : ASControlNode {
  public let textLabel = ASTextNode()
  public var textField = ASEditableTextNode()
  private var title: String
  private var placeholderText: String
  private var defaultText: String
  private var numberOflines: Int
  
  private let verticalPadding: CGFloat = 10.0

  public init(title: String, placeholderText: String = "", defaultText: String = "", numberOflines: Int = 1) {

    self.title = title
    self.placeholderText = placeholderText
    self.defaultText = defaultText
    self.numberOflines = numberOflines

    super.init()

    automaticallyManagesSubnodes = true
    configureSelf()
  }

  public required init?(coder: NSCoder) {
    fatalError()
  }
  
  private func configureSelf() {
    // AttributedTexts
    textLabel.attributedText = NSAttributedString(
    string: title,
    attributes: [
      .font: UIFont.fableFont(16.0, weight: .semibold),
      .foregroundColor : UIColor.fableBlack
    ])
    textField.attributedText = NSAttributedString(string: defaultText,
    attributes: [
      .font: UIFont.fableFont(16.0, weight: .regular),
      .foregroundColor : UIColor.fableBlack,
    ])
    textField.attributedPlaceholderText = NSAttributedString(string: placeholderText,
    attributes: [
      .foregroundColor : UIColor.fableDarkGray,
    ])

    // For multi-line text fields
    let textFieldHeight = CGFloat((numberOflines > 1 ? numberOflines - 1 : numberOflines) * 35)
    textField.style.height = ASDimensionMake(textFieldHeight)
    // To apply corner radius
    textField.layer.cornerRadius = 10.0
    textField.backgroundColor = .fableWhite
    
    // Set Insets
    let textPadding: CGFloat = 10.0
    textLabel.textContainerInset = UIEdgeInsets.init(top: verticalPadding, left: 0.0 , bottom: verticalPadding, right: 0.0)
    textField.textContainerInset = UIEdgeInsets.init(top: verticalPadding, left: textPadding, bottom: verticalPadding, right: textPadding)
  }

  public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

    let editableTextStack = ASStackLayoutSpec.vertical()
    editableTextStack.style.flexShrink = 1.0
    editableTextStack.style.flexGrow = 1.0
    editableTextStack.children = [textLabel, textField]
    
    let insets = UIEdgeInsets(top: verticalPadding, left: 0.0, bottom: 0.0, right: 0.0)
    let insetWrapper = ASInsetLayoutSpec(insets: insets, child: editableTextStack)

    return insetWrapper
  }

  public override func layout() {
    textField.shadowOpacity = 0.5
    textField.shadowColor = UIColor.fableDarkGray.cgColor
    textField.shadowRadius = 8.0
    textField.shadowOffset = CGSize(width: 0.0, height: 0.0)

    let shadowOutset = CGFloat(0.0)
    textField.layer.shadowPath = UIBezierPath(rect: CGRect(x: -shadowOutset, y: -shadowOutset, width: textField.bounds.width + shadowOutset, height : textField.bounds.height + shadowOutset)).cgPath
  }

  public func setText(text: String) {
    textField.attributedText = NSAttributedString(string: text)
  }
}
