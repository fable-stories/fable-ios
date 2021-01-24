//
//  FBASButtonNode.swift
//
//  Created by Madan U S on 21/11/20.
//

import Foundation
import FableSDKUIFoundation
import AsyncDisplayKit

public class FBSDKButtonNodeWithLabel: ASDisplayNode {
  public let buttonLabel = ASTextNode()
  public var buttonField = ASButtonNode()
  public var onTap: (() -> Void)?
  private var title: String
  
  private let verticalPadding: CGFloat = 10.0

  public init(title: String) {

    self.title = title
    super.init()

    automaticallyManagesSubnodes = true
    configureSelf()
  }
  
  public required init?(coder: NSCoder) {
    fatalError()
  }

  private func configureSelf() {
    // AttributedTexts
    buttonLabel.attributedText = NSAttributedString(
      string: title,
    attributes: [
      .font: UIFont.fableFont(16.0, weight: .semibold),
      .foregroundColor : UIColor.fableBlack
    ])
    buttonField.setAttributedTitle(NSAttributedString(string: title,
    attributes: [
      .font: UIFont.fableFont(16.0, weight: .regular),
      .foregroundColor : UIColor.fableBlack,
    ]), for: .normal)

    // For multi-line text fields
    let buttonFieldHeight = CGFloat(35)
    buttonField.style.height = ASDimensionMake(buttonFieldHeight)
    buttonField.layer.cornerRadius = 10.0
    buttonField.isOpaque = true
    buttonField.backgroundColor = .fableWhite
    
    // Set Insets
    let textPadding: CGFloat = 10.0
    buttonField.contentEdgeInsets = UIEdgeInsets.init(top: verticalPadding, left: textPadding, bottom: verticalPadding, right: textPadding)

    
    buttonField.addTarget(self, action: #selector(onTappedEvent), forControlEvents: .touchUpInside)
  }
  
  @objc private func onTappedEvent() {
    guard let onTap = self.onTap else { return }
    onTap()
  }
  
  public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

    let buttonStack = ASStackLayoutSpec.vertical()
    buttonStack.style.flexShrink = 1.0
    buttonStack.style.flexGrow = 1.0
    buttonStack.spacing = verticalPadding
    buttonStack.children = [buttonLabel, buttonField]
    
    let insets = UIEdgeInsets(top: verticalPadding, left: 0.0, bottom: 0.0, right: 0.0)
    let insetWrapper = ASInsetLayoutSpec(insets: insets, child: buttonStack)

    return insetWrapper
  }

  public override func layout() {

    buttonField.shadowOpacity = 0.5
    buttonField.shadowColor = UIColor.fableDarkGray.cgColor
    buttonField.shadowRadius = 8.0
    buttonField.shadowOffset = CGSize(width: 0.0, height: 0.0)

    let shadowOutset = CGFloat(0.0)
    buttonField.layer.shadowPath = UIBezierPath(rect: CGRect(x: -shadowOutset, y: -shadowOutset, width: buttonField.bounds.width + shadowOutset, height : buttonField.bounds.height + shadowOutset)).cgPath
  }

  public func setTitle(title: String) {
    buttonField.setAttributedTitle(NSAttributedString(string: title), for: .normal)
  }
}
