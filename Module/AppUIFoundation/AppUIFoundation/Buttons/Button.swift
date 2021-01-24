//
//  Button.swift
//  App
//
//  Created by Andrew Aquino on 4/9/19.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import AppFoundation

public protocol ButtonViewModelProtocol {
  var viewModel: ButtonViewModel { get }
}

public struct ButtonViewModel: ButtonViewModelProtocol {
  public enum CornerStyle {
    case pill
    case none
    var cornerRadius: CGFloat {
      switch self {
      case .pill: return 8.0
      case .none: return 0.0
      }
    }
  }
  
  public let font: UIFont?
  public let highlightedFont: UIFont?
  public let selectedFont: UIFont?
  public let textAlignment: NSTextAlignment?
  public let textColor: UIColor?
  public let highlightedTextColor: UIColor
  public let selectedTextColor: UIColor
  public let backgroundColor: UIColor
  public let selectedBackgroundColor: UIColor
  public let highlightedBackgroundColor: UIColor
  public let disabledBackgroundColor: UIColor
  public let cornerStyle: CornerStyle
  public let underline: Bool
  public let titleEdgeInsets: UIEdgeInsets
  
  public init(
    font: UIFont?,
    highlightedFont: UIFont?,
    selectedFont: UIFont?,
    textAlignment: NSTextAlignment?,
    textColor: UIColor?,
    highlightedTextColor: UIColor,
    selectedTextColor: UIColor,
    backgroundColor: UIColor,
    selectedBackgroundColor: UIColor,
    highlightedBackgroundColor: UIColor,
    disabledBackgroundColor: UIColor,
    cornerStyle: CornerStyle,
    underline: Bool,
    titleEdgeInsets: UIEdgeInsets
  ) {
    self.font = font
    self.highlightedFont = highlightedFont
    self.selectedFont = selectedFont
    self.textColor = textColor
    self.textAlignment = textAlignment
    self.highlightedTextColor = highlightedTextColor
    self.selectedTextColor = selectedTextColor
    self.backgroundColor = backgroundColor
    self.selectedBackgroundColor = selectedBackgroundColor
    self.highlightedBackgroundColor = highlightedBackgroundColor
    self.disabledBackgroundColor = disabledBackgroundColor
    self.cornerStyle = cornerStyle
    self.underline = underline
    self.titleEdgeInsets = titleEdgeInsets
  }
  
  public var viewModel: ButtonViewModel { return self }
}

open class Button: UIButton {
  private let viewModel: ButtonViewModel
  
  private var loadingView: UIActivityIndicatorView?
  
  public var title: String? {
    get { return titleLabel?.attributedText?.string }
    set { self.setTitle(newValue, for: .normal) }
  }

  public var isLoading: Bool = false {
    didSet {
      updateView()
    }
  }
  
  internal lazy var mutableIsHighlighted = MutableProperty<Bool>(self.isHighlighted)
  
  open override var isHighlighted: Bool {
    get {
      return super.isHighlighted
    } set {
      super.isHighlighted = newValue
      mutableIsHighlighted.value = newValue
      updateView()
    }
  }
  
  internal lazy var mutableIsSelected = MutableProperty<Bool>(self.isHighlighted)

  open override var isSelected: Bool {
    get {
      return super.isSelected
    } set {
      super.isSelected = newValue
      mutableIsSelected.value = newValue
      updateView()
    }
  }
  
  open override var isEnabled: Bool {
    get {
      return super.isEnabled
    } set {
      super.isEnabled = newValue
      updateView()
    }
  }

  public init(_ viewModel: ButtonViewModelProtocol) {
    self.viewModel = viewModel.viewModel
    super.init(frame: .zero)
    configureSelf()
    configureReactive()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError()
  }
  
  private func configureSelf() {
    layer.cornerRadius = viewModel.cornerStyle.cornerRadius
    titleEdgeInsets = viewModel.titleEdgeInsets
    updateView()
  }
  
  private func configureReactive() {
  }
  
  open override func setTitle(_ title: String?, for state: UIControl.State) {
    contentHorizontalAlignment = {
      guard let textAlignment = viewModel.textAlignment else { return .center }
      switch textAlignment {
      case .left: return .left
      case .right: return .right
      case .center: return .center
      default: return .center
      }
    }()
    super.setAttributedTitle(title?.toAttributedString(.styled(
      viewModel.textColor,
      font: viewModel.font,
      alignment: viewModel.textAlignment,
      underline: viewModel.underline
      )), for: state)
    super.setAttributedTitle(title?.toAttributedString(.styled(
      viewModel.highlightedTextColor,
      font: viewModel.highlightedFont,
      alignment: viewModel.textAlignment,
      underline: viewModel.underline
      )), for: .highlighted)
    super.setAttributedTitle(title?.toAttributedString(.styled(
      viewModel.selectedTextColor,
      font: viewModel.selectedFont,
      alignment: viewModel.textAlignment,
      underline: viewModel.underline
      )), for: .selected)
  }
  
  open override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
    isHighlighted = true
  }
  
  open override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
    isHighlighted = false
    isSelected = !isSelected
  }
  
  private func updateView() {
    var backgroundColor: UIColor {
      if isEnabled {
        if isHighlighted {
          return viewModel.highlightedBackgroundColor
        }
        if isSelected {
          return viewModel.selectedBackgroundColor
        }
        return viewModel.backgroundColor
      }
      return viewModel.disabledBackgroundColor
    }
    self.backgroundColor = backgroundColor

    if isLoading {
      if loadingView == nil {
        titleLabel?.layer.opacity = 0.0
        let loadingView: UIActivityIndicatorView = {
          if #available(iOS 13.0, *) {
            return UIActivityIndicatorView(style: .medium)
          } else {
            return UIActivityIndicatorView(style: .white)
          }
        }()
        self.loadingView = loadingView
        loadingView.startAnimating()
        addSubview(loadingView)
        loadingView.snp.makeConstraints { make in
          make.edges.equalToSuperview()
        }
      }
    } else {
      titleLabel?.layer.opacity = 1.0
      subviews.compactMap { $0 as? UIActivityIndicatorView }.forEach { $0.removeFromSuperview() }
      loadingView = nil
    }
  }
}

extension Reactive where Base: Button {
  public var isLoading: BindingTarget<Bool> {
    return makeBindingTarget { $0.isLoading = $1 }
  }
  
  public var highlighted : ReactiveSwift.Property<Bool> {
    return base.mutableIsHighlighted.map { $0 }
  }
  
  public var selected: ReactiveSwift.Property<Bool> {
    return base.mutableIsSelected.map { $0 }
  }
}
