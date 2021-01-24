//
//  BorderViewModel+Extensions.swift
//  Fable
//
//  Created by Andrew Aquino on 7/21/19.
//

import AppFoundation
import UIKit

public enum FableBorderViewModel: BorderViewModelProtocol {
  case regular
  case none

  public var viewModel: BorderViewModel {
    switch self {
    case .regular:
      return BorderViewModel(
        color: .fableGray,
        width: 1.0
      )
    case .none:
      return BorderViewModel(
        color: .clear,
        width: 0.0
      )
    }
  }
}
