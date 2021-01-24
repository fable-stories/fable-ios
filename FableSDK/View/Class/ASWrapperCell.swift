//
//  ASWrapperCell.swift
//  FableSDKViews
//
//  Created by Andrew Aquino on 12/27/20.
//

import Foundation
import AsyncDisplayKit

public class ASWrapperCell<T: ASDisplayNode>: ASCellNode {
  
  public let child: T
  
  public init(child: T) {
    self.child = child
    super.init()
    self.automaticallyManagesSubnodes = true
    self.selectionStyle = .none
  }

  public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    ASWrapperLayoutSpec(layoutElement: child)
  }
}
