//
//  UIView+Extensions.swift
//  Fable
//
//  Created by Andrew Aquino on 7/21/19.
//

import UIKit

extension UIView {
  public func roundedCorners(_ corners: UIRectCorner, radius: CGFloat) {
    if #available(iOS 11.0, *) {
      clipsToBounds = true
      layer.cornerRadius = radius
      layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
    } else {
      DispatchQueue.main.async {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
      }
    }
  }
}

public extension NSObject {
  func also<T: NSObject>(_ closure: @escaping (T) -> Void) -> T {
    closure(self as! T)
    return self as! T
  }
}
