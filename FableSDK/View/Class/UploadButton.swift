//
//  UploadButton.swift
//  AppFoundation
//
//  Created by Will on 7/7/20.
//

import AppFoundation
import ReactiveCocoa
import ReactiveSwift
import UIKit

public protocol UploadButtonViewModelProtocol {
  var viewModel: UploadButtonViewModel { get }
}

public struct UploadButtonViewModel: UploadButtonViewModelProtocol {
  public enum CornerStyle {
    case circle
    case square
    var cornerRadius: CGFloat {
      switch self {
      case .square: return 8.0
      case .circle: return 0.0
      }
    }
  }

  public enum ButtonStyle {
    case tall
    case long
    case circle
    case square
    var buttonType: CGSize {
      switch self {
      case .long: return CGSize(width: 300, height: 155)
      case .tall: return CGSize(width: 120, height: 155)
      case .circle: return CGSize(width: 155, height: 155)
      case .square: return CGSize(width: 155, height: 155)
      }
    }
  }

  public let backgroundColor: UIColor
  public let selectedBackgroundColor: UIColor
  public let disabledBackgroundColor: UIColor
  public let cornerStyle: CornerStyle
  public let buttonStyle: ButtonStyle
  public let buttonShadow: ShadowViewModel

  public init(
    backgroundColor: UIColor,
    selectedBackgroundColor: UIColor,
    disabledBackgroundColor: UIColor,
    cornerStyle: CornerStyle,
    buttonStyle: ButtonStyle,
    buttonShadow: ShadowViewModel
  ) {
    self.backgroundColor = backgroundColor
    self.selectedBackgroundColor = selectedBackgroundColor
    self.disabledBackgroundColor = disabledBackgroundColor
    self.cornerStyle = cornerStyle
    self.buttonStyle = buttonStyle
    self.buttonShadow = buttonShadow
  }

  public var viewModel: UploadButtonViewModel { self }
}

open class UploadButton: UIButton {
  private let viewModel: UploadButtonViewModel
  private var loadingView: UIActivityIndicatorView?

  public var title: String? {
    get { titleLabel?.attributedText?.string }
    set { setTitle(newValue, for: .normal) }
  }

  public var isLoading: Bool = false {
    didSet {
      updateView()
    }
  }

  override open var isEnabled: Bool {
    get {
      super.isEnabled
    } set {
      super.isEnabled = newValue
      updateView()
    }
  }

  private let uploadImage = UIImageView.new {
    $0.image = #imageLiteral(resourceName: "uploadIcon")
    $0.isUserInteractionEnabled = false
  }

  private let uploadText = UILabel.new {
    $0.text = "Upload image"
    $0.textColor = .blue
    $0.font = .fableFont(12, weight: .semibold)
    $0.isUserInteractionEnabled = false
  }

  public init(_ viewModel: UploadButtonViewModelProtocol) {
    self.viewModel = viewModel.viewModel
    super.init(frame: .zero)
    configureSelf()
    configureLayout()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  private func configureSelf() {
    updateView()
  }

  override open func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
    isHighlighted = true
  }

  override open func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
    isHighlighted = false
    isSelected = !isSelected
  }

  private func updateView() {
    let backgroundColor: UIColor = {
      if isEnabled {
        if isSelected {
          return viewModel.selectedBackgroundColor
        }
        return viewModel.backgroundColor
      }
      return viewModel.disabledBackgroundColor
    }()
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
      loadingView?.isHidden = false
    } else {
      titleLabel?.layer.opacity = 1.0
      subviews.compactMap { $0 as? UIActivityIndicatorView }.forEach { $0.removeFromSuperview() }
      loadingView = nil
      loadingView?.isHidden = true
    }
  }

  override open func layoutSubviews() {
    super.layoutSubviews()
    layer.frame.size = viewModel.buttonStyle.buttonType
    addShadow(viewModel.buttonShadow)
    addSubview(uploadText)
    addSubview(uploadImage)

    switch self.viewModel.cornerStyle {
    case .circle:
      let buttonWidth = frame.width
      layer.cornerRadius = buttonWidth / 2.0
    default:
      break
    }
    layer.cornerRadius = viewModel.cornerStyle.cornerRadius
  }

  private func configureLayout() {
    uploadImage.snp.makeConstraints { make in
      make.centerX.equalTo(self.snp.centerX)
      make.bottom.equalTo(self.snp.centerY).offset(-10)
    }
    uploadText.snp.makeConstraints { make in
      make.centerX.equalTo(self.snp.centerX)
      make.top.equalTo(uploadImage.snp.bottom).offset(10)
    }
  }
}

public struct FableUploadButtonViewModel {
  public static func long() -> UploadButtonViewModelProtocol {
    UploadButtonViewModel(
      backgroundColor: .fableWhite,
      selectedBackgroundColor: .fableOffWhite,
      disabledBackgroundColor: .fableGray,
      cornerStyle: .square,
      buttonStyle: .long,
      buttonShadow: ShadowViewModel(color: .black, offset: .init(width: 4, height: 4), radius: 30, opacity: 10)
    )
  }

  public static func tall() -> UploadButtonViewModelProtocol {
    UploadButtonViewModel(
      backgroundColor: .fableWhite,
      selectedBackgroundColor: .fableOffWhite,
      disabledBackgroundColor: .fableGray,
      cornerStyle: .square,
      buttonStyle: .tall,
      buttonShadow: ShadowViewModel(color: .black, offset: .init(width: 4, height: 4), radius: 30, opacity: 10)
    )
  }

  public static func circle() -> UploadButtonViewModelProtocol {
    UploadButtonViewModel(
      backgroundColor: .fableWhite,
      selectedBackgroundColor: .fableOffWhite,
      disabledBackgroundColor: .fableGray,
      cornerStyle: .circle,
      buttonStyle: .circle,
      buttonShadow: ShadowViewModel(color: .black, offset: .init(width: 4, height: 4), radius: 30, opacity: 10)
    )
  }

  public static func square() -> UploadButtonViewModelProtocol {
    UploadButtonViewModel(
      backgroundColor: .fableWhite,
      selectedBackgroundColor: .fableOffWhite,
      disabledBackgroundColor: .fableGray,
      cornerStyle: .square,
      buttonStyle: .square,
      buttonShadow: ShadowViewModel(color: .black, offset: .init(width: 4, height: 4), radius: 30, opacity: 10)
    )
  }
}
