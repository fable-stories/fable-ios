//
//  UIColor+Extensions.swift
//  AppFoundation
//
//  Created by Andrew Aquino on 3/27/19.
//

import UIKit

extension UIColor {
  public convenience init(_ hexString: String, alpha: CGFloat = 1.0) {
    var cString:String = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
      cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
      self.init()
    }
    
    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)
    
    self.init(
      red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
      alpha: CGFloat(1.0)
    )
  }
  
  public var hexString: String {
    var r:CGFloat = 0
    var g:CGFloat = 0
    var b:CGFloat = 0
    var a:CGFloat = 0
    getRed(&r, green: &g, blue: &b, alpha: &a)
    let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
    return String(format:"#%06x", rgb)
  }
  
  public func lighter(by percentage: CGFloat = 30.0) -> UIColor {
    return self.adjust(by: abs(percentage) )
  }
  
  public func darker(by percentage: CGFloat = 30.0) -> UIColor {
    return self.adjust(by: -1 * abs(percentage) )
  }
  
  public func adjust(by percentage: CGFloat = 30.0) -> UIColor {
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
    guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return self }
    return UIColor(
      red: min(red + percentage / 100, 1.0),
      green: min(green + percentage / 100, 1.0),
      blue: min(blue + percentage / 100, 1.0),
      alpha: alpha
    )
  }
  
  public static func random(alpha: CGFloat? = nil) -> UIColor {
    return UIColor(
      red: CGFloat.random(in: 0...1),
      green: CGFloat.random(in: 0...1),
      blue: CGFloat.random(in: 0...1),
      alpha: alpha ?? CGFloat.random(in: 0.1...1)
    )
  }
}
