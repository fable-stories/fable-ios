//
//  AnimationNode.swift
//  FableSDKViews
//
//  Created by Andrew Aquino on 12/13/20.
//

import Foundation
import AsyncDisplayKit
import Lottie

public class AnimationNode: ASDisplayNode {
  public let animationView: AnimationView
  private let animationName: String
  
  public init(animationName: String) {
    let animationView = AnimationView(name: animationName)
    animationView.loopMode = .loop
    animationView.contentMode = .scaleAspectFit
    self.animationView = animationView
    self.animationName = animationName
    super.init()
    
    self.setViewBlock { animationView }
  }
  
  public func play() {
    animationView.play()
  }
  
  public func stop() {
    animationView.stop()
  }
}
