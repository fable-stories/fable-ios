//
//  MyUserProfileNode.swift
//  FableSDKViews
//
//  Created by Andrew Aquino on 12/27/20.
//

import Foundation
import AsyncDisplayKit

public class MyUserProfileNode: ASDisplayNode {
  private lazy var scrollNode: ASScrollNode = .new {
    let node = ASScrollNode()
    node.scrollableDirections = [.up, .down]
    return node
  }
  
  public override init() {
    super.init()
  }
}
