//
//  FBSDKIconButtonNode.swift
//  FableSDKViews
//
//  Created by Andrew Aquino on 12/28/20.
//

import Foundation
import AsyncDisplayKit

public class FBSDKIconButtonNode: ASButtonNode {
  private let animationNode = AnimationNode(animationName: "loading_indicator")
  
  public var isLoading: Bool = false {
    didSet {
      self.imageNode.isHidden = isLoading
      self.isUserInteractionEnabled = !isLoading
      if isLoading {
        self.animationNode.play()
      } else {
        self.animationNode.stop()
      }
    }
  }
  
  public var isDisabled: Bool = false {
    didSet {
      self.isUserInteractionEnabled = !isDisabled
      self.imageNode.tintColor = isDisabled ? UIColor.gray : primaryColor
    }
  }
  
  private let primaryColor: UIColor
  
  public init(primaryColor: UIColor) {
    self.primaryColor = primaryColor
    super.init()
    self.imageNode.contentMode = .center
    self.automaticallyManagesSubnodes = true
  }
  
  public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    self.animationNode.style.preferredSize = .sizeWithConstantDimensions(24.0)
    return ASOverlayLayoutSpec(
      child: imageNode,
      overlay: ASWrapperLayoutSpec(layoutElement: animationNode)
    )
  }
}

