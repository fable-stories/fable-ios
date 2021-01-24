//
//  MyUserProfileViewController.swift
//  FableSDKViewControllers
//
//  Created by Andrew Aquino on 12/27/20.
//

import Foundation
import AsyncDisplayKit
import FableSDKResolver
import FableSDKModelObjects
import FableSDKViews
import FableSDKModelManagers
import AppFoundation

public class MyUserProfileViewController: ASDKViewController<MyUserProfileNode> {
  
  private let resolver: FBSDKResolver

  public init(resolver: FBSDKResolver) {
    self.resolver = resolver
    super.init(node: .init())
  }
  
  public required init?(coder: NSCoder) {
    fatalError()
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
  }
}
