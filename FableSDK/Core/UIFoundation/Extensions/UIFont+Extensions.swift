//
//  UIFont+Extensions.swift
//  AppFoundation
//
//  Created by Andrew Aquino on 3/27/19.
//

import UIKit

extension UIFont {
  /*
    *** Avenir Next ***
    AvenirNext-Bold
    AvenirNext-BoldItalic
    AvenirNext-DemiBold
    AvenirNext-DemiBoldItalic
    AvenirNext-Heavy
    AvenirNext-HeavyItalic
    AvenirNext-Italic
    AvenirNext-Medium
    AvenirNext-MediumItalic
    AvenirNext-Regular
    AvenirNext-UltraLight
    AvenirNext-UltraLightItalic
   */
  public static func fableFont(_ ofSize: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
    var fontName: String {
      switch weight {
      case .ultraLight: return "SofiaPro-UltraLight"
      case .light: return "SofiaPro-Light"
      case .regular: return "SofiaPro-Regular"
      case .medium: return "SofiaPro-Medium"
      case .semibold: return "SofiaPro-SemiBold"
      case .bold: return "SofiaPro-Bold"
      case .black: return "SofiaPro-Black"
      default: return ""
      }
    }
    return UIFont(name: fontName, size: ofSize) ?? .systemFont(ofSize: ofSize, weight: weight)
  }
}
