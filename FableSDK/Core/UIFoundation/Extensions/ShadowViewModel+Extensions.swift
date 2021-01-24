//
//  ShadowViewModel+Extensions.swift
//  Fable
//
//  Created by Andrew Aquino on 7/21/19.
//

import AppFoundation
import UIKit

public enum FableShadowViewModel: ShadowViewModelProtocol {
  case light
  case regular

  public var viewModel: ShadowViewModel {
    switch self {
    case .light: return ShadowViewModel(
      color: .fableBlack,
      offset: CGSize(width: 0.0, height: 3.0),
      radius: 4.0,
      opacity: 0.05
    )
    case .regular: return ShadowViewModel(
      color: .fableBlack,
      offset: CGSize(width: 0.0, height: 1.0),
      radius: 1.0,
      opacity: 0.4
    )
    }
  }
}
