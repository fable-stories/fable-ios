//
//  ASButtonWrapperNode.swift
//  FableSDKViews
//
//  Created by Andrew Aquino on 12/28/20.
//

import Foundation
import AsyncDisplayKit

public final class ASButtonWrapperNode: ASControlNode {
  
  private let child: ASLayoutElement
  private let insets: UIEdgeInsets
  
  public init(child: ASLayoutElement, insets: UIEdgeInsets = .zero) {
    self.child = child
    self.insets = insets
    super.init()
    self.automaticallyManagesSubnodes = true
  }

  public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    return ASInsetLayoutSpec(insets: insets, child: child)
  }
}
