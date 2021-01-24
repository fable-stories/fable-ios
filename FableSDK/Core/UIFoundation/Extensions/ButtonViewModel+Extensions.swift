//
//  ButtonViewModel+Extensions.swift
//  Fable
//
//  Created by Andrew Aquino on 10/16/19.
//

import AppFoundation
import AppUIFoundation
import UIKit

public struct FableButtonViewModel {
  public static func action() -> ButtonViewModelProtocol {
    ButtonViewModel(
      font: .fableFont(14.0, weight: .bold),
      highlightedFont: .fableFont(14.0, weight: .bold),
      selectedFont: .fableFont(14.0, weight: .bold),
      textAlignment: .center,
      textColor: .white,
      highlightedTextColor: .fableWhite,
      selectedTextColor: .fableBlack,
      backgroundColor: .fableBlack,
      selectedBackgroundColor: .fableMidBlack,
      highlightedBackgroundColor: .fableMidBlack,
      disabledBackgroundColor: .fableDarkGray,
      cornerStyle: .pill,
      underline: false,
      titleEdgeInsets: UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
    )
  }

  public static func plain(textAlignment: NSTextAlignment = .natural) -> ButtonViewModelProtocol {
    ButtonViewModel(
      font: .fableFont(14.0, weight: .semibold),
      highlightedFont: .fableFont(14.0, weight: .semibold),
      selectedFont: .fableFont(14.0, weight: .semibold),
      textAlignment: textAlignment,
      textColor: .fableBlack,
      highlightedTextColor: .fableDarkGray,
      selectedTextColor: .fableRed,
      backgroundColor: .clear,
      selectedBackgroundColor: .clear,
      highlightedBackgroundColor: .clear,
      disabledBackgroundColor: .clear,
      cornerStyle: .none,
      underline: false,
      titleEdgeInsets: UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
    )
  }

  public static func plainUnderline() -> ButtonViewModelProtocol {
    ButtonViewModel(
      font: .fableFont(14.0, weight: .semibold),
      highlightedFont: .fableFont(14.0, weight: .semibold),
      selectedFont: .fableFont(14.0, weight: .semibold),
      textAlignment: .center,
      textColor: .fableDarkGray,
      highlightedTextColor: .fableBlack,
      selectedTextColor: .fableRed,
      backgroundColor: .clear,
      selectedBackgroundColor: .clear,
      highlightedBackgroundColor: .clear,
      disabledBackgroundColor: .clear,
      cornerStyle: .none,
      underline: true,
      titleEdgeInsets: UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
    )
  }

  public static func caption() -> ButtonViewModelProtocol {
    ButtonViewModel(
      font: .fableFont(14.0, weight: .semibold),
      highlightedFont: .fableFont(14.0, weight: .semibold),
      selectedFont: .fableFont(14.0, weight: .semibold),
      textAlignment: .center,
      textColor: .fableDarkGray,
      highlightedTextColor: .fableGray,
      selectedTextColor: .fableRed,
      backgroundColor: .clear,
      selectedBackgroundColor: .clear,
      highlightedBackgroundColor: .clear,
      disabledBackgroundColor: .clear,
      cornerStyle: .none,
      underline: false,
      titleEdgeInsets: UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
    )
  }

  public static func selectorPlain() -> ButtonViewModelProtocol {
    ButtonViewModel(
      font: .fableFont(14.0, weight: .regular),
      highlightedFont: .fableFont(14.0, weight: .regular),
      selectedFont: .fableFont(14.0, weight: .semibold),
      textAlignment: .center,
      textColor: .fableMediumGray,
      highlightedTextColor: .fableGray,
      selectedTextColor: .fableBlack,
      backgroundColor: .clear,
      selectedBackgroundColor: .clear,
      highlightedBackgroundColor: .clear,
      disabledBackgroundColor: .clear,
      cornerStyle: .none,
      underline: false,
      titleEdgeInsets: UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
    )
  }

  public static func primaryButton() -> ButtonViewModelProtocol {
    ButtonViewModel(
      font: .fableFont(14, weight: .regular),
      highlightedFont: .fableFont(14, weight: .regular),
      selectedFont: .fableFont(14, weight: .semibold),
      textAlignment: .center,
      textColor: .fableWhite,
      highlightedTextColor: .fableWhite,
      selectedTextColor: .fableWhite,
      backgroundColor: .fableBlue,
      selectedBackgroundColor: .fableDarkBlue,
      highlightedBackgroundColor: .fableDarkBlue,
      disabledBackgroundColor: .clear,
      cornerStyle: .pill,
      underline: false,
      titleEdgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    )
  }
}
