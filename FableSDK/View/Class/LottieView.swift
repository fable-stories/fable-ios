//
//  LottieView.swift
//  FableSDKViews
//
//  Created by Andrew Aquino on 10/21/20.
//

import Foundation
import Lottie

public class LottieView: UIView {
  private let filePath: String
  
  private let animationView: AnimationView
  
  public init(filePath: String) {
    self.filePath = filePath
    self.animationView = AnimationView(filePath: filePath)
    super.init(frame: .zero)
  }
  
  public required init?(coder: NSCoder) {
    fatalError()
  }
}
