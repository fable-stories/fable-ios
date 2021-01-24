//
//  TextAttributes+Extensions.swift
//  Fable
//
//  Created by Andrew Aquino on 7/27/19.
//

import AppFoundation
import UIKit

extension TextAttributes {
  public static func title13(_ color: UIColor = .fableBlack, alignment: NSTextAlignment = .natural) -> TextAttributes {
    .styled(
      color,
      font: .fableFont(13.0, weight: .semibold),
      alignment: alignment
    )
  }

  public static func titleBold14(_ color: UIColor = .fableBlack, alignment: NSTextAlignment = .natural) -> TextAttributes {
    .styled(
      color,
      font: .fableFont(14.0, weight: .bold),
      alignment: alignment
    )
  }

  public static func title16(_ color: UIColor = .fableBlack, alignment: NSTextAlignment = .natural) -> TextAttributes {
    .styled(
      color,
      font: .fableFont(16.0, weight: .semibold),
      alignment: alignment
    )
  }

  public static func body12(_ color: UIColor = .fableBlack, alignment: NSTextAlignment = .natural) -> TextAttributes {
    .styled(
      color,
      font: .fableFont(12.0, weight: .regular),
      alignment: alignment
    )
  }

  public static func body16(_ color: UIColor = .fableBlack, alignment: NSTextAlignment = .natural) -> TextAttributes {
    .styled(
      color,
      font: .fableFont(16.0, weight: .regular),
      alignment: alignment
    )
  }

  public static func body14(_ color: UIColor = .fableBlack, alignment: NSTextAlignment = .natural) -> TextAttributes {
    .styled(
      color,
      font: .fableFont(14.0, weight: .regular),
      alignment: alignment
    )
  }

  public static func bodySemibold14(_ color: UIColor = .fableBlack, alignment: NSTextAlignment = .natural) -> TextAttributes {
    .styled(
      color,
      font: .fableFont(14.0, weight: .semibold),
      alignment: alignment
    )
  }

  public static func bodyBold14(_ color: UIColor = .fableBlack, alignment: NSTextAlignment = .natural) -> TextAttributes {
    .styled(
      color,
      font: .fableFont(14.0, weight: .bold),
      alignment: alignment
    )
  }

  public static func placeholderRegular14(_ color: UIColor = .fableDarkGray, alignment: NSTextAlignment = .natural) -> TextAttributes {
    .styled(
      color,
      font: .fableFont(14.0, weight: .regular),
      alignment: alignment
    )
  }
}
