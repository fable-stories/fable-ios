//
//  TextAttributes.swift
//  AppFoundation
//
//  Created by Andrew Aquino on 7/27/19.
//

import UIKit

public typealias TextAttributes = [NSAttributedString.Key: Any]

extension TextAttributes {
  public var font: UIFont? {
    return self[.font] as? UIFont
  }
  
  public var textColor: UIColor? {
    return self[.foregroundColor] as? UIColor
  }
  
  public var textAlignment: NSTextAlignment? {
    return paragraphStyle?.alignment
  }
  
  public var paragraphStyle: NSParagraphStyle? {
    return self[.paragraphStyle] as? NSMutableParagraphStyle
  }
  
  public mutating func updatingValue(_ value: Value, forKey key: Key) -> Self {
    self.updateValue(value, forKey: key)
    return self
  }
}

extension NSAttributedString {
  public var attributes: TextAttributes {
    return self.attributes(at: 0, effectiveRange: nil)
  }
}

extension UILabel {
  @objc
  public var attributes: TextAttributes {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineBreakMode = lineBreakMode
    paragraphStyle.alignment = textAlignment
    return [
      .foregroundColor: textColor,
      .font: font,
      .paragraphStyle: paragraphStyle
    ].compactMapValues { $0 }
  }
}

public extension UITextView {
  @objc
  var attributes: TextAttributes {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineBreakMode = self.textContainer.lineBreakMode
    paragraphStyle.alignment = textAlignment
    return [
      .foregroundColor: textColor,
      .font: font,
      .paragraphStyle: paragraphStyle
    ].compactMapValues { $0 }
  }
  
  func setTextAttributes(_ textAttributes: TextAttributes) {
    self.font = textAttributes.font
    self.textColor = textAttributes.textColor
    self.textAlignment = textAttributes.textAlignment ?? self.textAlignment
    let paragraphStyle = textAttributes.paragraphStyle
    let lineBreakMode = self.textContainer.lineBreakMode
    self.textContainer.lineBreakMode = paragraphStyle?.lineBreakMode ?? lineBreakMode
  }
}

extension UILabel {
  public func setTextAttributes(_ textAttributes: TextAttributes) {
    self.font = textAttributes.font
    self.textColor = textAttributes.textColor
    self.textAlignment = textAttributes.textAlignment ?? self.textAlignment
    let paragraphStyle = textAttributes.paragraphStyle
    self.lineBreakMode = paragraphStyle?.lineBreakMode ?? self.lineBreakMode
  }
}
