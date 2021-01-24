//
//  UINavigationBar+Extensions.swift
//  AppFoundation
//
//  Created by Andrew Aquino on 4/21/19.
//

import UIKit

extension UINavigationBar {
  public class func setNavigationBarTransparent(_ caller: UIViewController?) {
    let navigationBar = caller?.navigationController?.navigationBar ?? UINavigationBar.appearance()
    navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationBar.backgroundColor = .clear
    navigationBar.isTranslucent = false
  }
  
  public class func setNavigationBarOpaque(_ caller: UIViewController?) {
    let navigationBar = caller?.navigationController?.navigationBar ?? UINavigationBar.appearance()
    navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationBar.backgroundColor = .white
    navigationBar.isTranslucent = false
  }

  public class func setBottomBorderColor(_ color: UIColor, caller: UIViewController? = nil) {
    let navigationBar = caller?.navigationController?.navigationBar ?? UINavigationBar.appearance()
    var image: UIImage {
      if color == .clear { return UIImage() }
      UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
      guard let context = UIGraphicsGetCurrentContext() else {
        UIGraphicsEndImageContext()
        return UIImage()
      }
      color.setFill()
      context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
      let image = UIGraphicsGetImageFromCurrentImageContext()
      return image ?? UIImage()
    }
    UIGraphicsEndImageContext()
    navigationBar.shadowImage = image
  }
}
