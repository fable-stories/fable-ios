//
//  UIGestureRecognizer+Extensions.swift
//  ReactiveFoundation
//
//  Created by Andrew Aquino on 10/11/19.
//

import UIKit
import ReactiveSwift

extension Reactive where Base: UIGestureRecognizer {
  public func recognized() -> Signal<Void, Never> {
    return stateChanged.compactMap { $0.state == .recognized ? $0 : nil }.mapVoid()
  }
}
