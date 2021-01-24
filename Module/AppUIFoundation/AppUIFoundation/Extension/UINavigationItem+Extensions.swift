//
//  UINavigationItem+Extensions.swift
//  AppFoundation
//
//  Created by Andrew Aquino on 11/19/19.
//

import UIKit

extension UINavigationItem {
  public static func makeTitleView(_ attributedText: NSAttributedString) -> UIView {
    let textView = UITextView()
    textView.isScrollEnabled = false
    textView.isUserInteractionEnabled = false
    textView.attributedText = attributedText
    textView.textContainerInset = .zero
    return textView
  }

  public static func makeTitleView(_ title: String, attributes: [NSAttributedString.Key: Any]) -> UIView {
    let textView = UITextView()
    textView.isScrollEnabled = false
    textView.isUserInteractionEnabled = false
    textView.text = title
    textView.font = attributes.font
    textView.textColor = attributes.textColor
    textView.textAlignment = attributes.textAlignment ?? .center
    textView.textContainerInset = .zero
    return textView
  }
}
