//
//  String+Extensions.swift
//  Fable
//
//  Created by Andrew Aquino on 6/30/19.
//

import AppFoundation
import UIKit

extension String {
  public func title13(_ color: UIColor = .fableBlack, alignment: NSTextAlignment = .natural) -> NSAttributedString {
    NSAttributedString(
      string: self,
      attributes: .title13(color, alignment: alignment)
    )
  }

  public func title16(_ color: UIColor = .fableBlack, alignment: NSTextAlignment = .natural) -> NSAttributedString {
    NSAttributedString(
      string: self,
      attributes: .title16(color, alignment: alignment)
    )
  }

  public func body16(_ color: UIColor = .fableBlack, alignment: NSTextAlignment = .natural) -> NSAttributedString {
    NSAttributedString(
      string: self,
      attributes: .body16(color, alignment: alignment)
    )
  }

  public func body14(_ color: UIColor = .fableBlack, alignment: NSTextAlignment = .natural) -> NSAttributedString {
    NSAttributedString(
      string: self,
      attributes: .body14(color, alignment: alignment)
    )
  }

  public func bodySemibold14(_ color: UIColor = .fableBlack, alignment: NSTextAlignment = .natural) -> NSAttributedString {
    NSAttributedString(
      string: self,
      attributes: .bodySemibold14(color, alignment: alignment)
    )
  }

  public func placeholderRegular14(_ color: UIColor = .fableDarkGray, alignment: NSTextAlignment = .natural) -> NSAttributedString {
    NSAttributedString(
      string: self,
      attributes: .placeholderRegular14(color, alignment: alignment)
    )
  }
}
