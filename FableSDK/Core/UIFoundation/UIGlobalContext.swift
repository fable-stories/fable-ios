//
//  UIGlobalContext.swift
//  FableSDKUIFoundation
//
//  Created by Andrew Aquino on 3/15/20.
//

import UIKit

public protocol UIGlobalContextReadOnly {
  func setFirstResponder(_ responder: UIResponder)
  func getFirstResonder() -> UIResponder?
}

public class UIGlobalContext {
  private static var firstResponder: UIResponder?

  public class func setFirstResponder(_ responder: UIResponder) {
    firstResponder = responder
  }

  public class func getFirstResonder() -> UIResponder? {
    firstResponder?.isFirstResponder == true ? firstResponder : nil
  }
}
