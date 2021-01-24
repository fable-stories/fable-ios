//
// Created by Andrew Aquino on 1/13/20.
//

import UIKit
import AppFoundation

extension UINavigationController {
  public func popViewController(animated: Bool, onComplete: VoidClosure?) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(onComplete)
    popViewController(animated: animated)
    CATransaction.commit()
  }
  
  public func pushViewController(_ viewController: UIViewController, animated: Bool, onComplete: VoidClosure?) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(onComplete)
    pushViewController(viewController, animated: animated)
    CATransaction.commit()
  }
}

