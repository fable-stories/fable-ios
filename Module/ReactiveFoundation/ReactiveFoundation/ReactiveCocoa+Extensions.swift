//
//  ReactiveCocoa+Extensions.swift
//  AppFoundation
//
//  Created by Andrew Aquino on 3/27/19.
//

import AppFoundation
import UIKit
import ReactiveSwift
import ReactiveCocoa


public protocol CocoaActionResponder {}
extension UIBarButtonItem: CocoaActionResponder {}
extension UIButton: CocoaActionResponder {}

extension CocoaAction where Sender: CocoaActionResponder {
  public static func invoke(_ action: Action<Void, Void, Never>) -> CocoaAction<Sender> {
    return CocoaAction<Sender>(action)
  }
  
  public static func invoke(_ closure: @escaping VoidClosure) -> CocoaAction<Sender> {
    return CocoaAction<Sender>(Action<(), (), Never> {
      closure()
      return .empty
    })
  }
}

extension Reactive where Base: UIButton {
}

extension Reactive where Base: UITextField {
  public var editing: Property<Bool> {
    return Property(
      initial: false,
      then: Signal.merge(
        controlEvents(.editingDidBegin).map { _ in true },
        controlEvents(.editingDidEnd).map { _ in false }
      )
    ).skipRepeats()
  }
  
  public var rightViewMode: BindingTarget<UITextField.ViewMode> {
    return makeBindingTarget { base, newValue in
      base.rightViewMode = newValue
    }
  }
}

extension Reactive where Base: UITableView {
  public var contentOffset: Signal<CGPoint, Never> {
    return base.reactive.signal(forKeyPath: "contentOffset").compactMap { $0 as? CGPoint }
  }
}
