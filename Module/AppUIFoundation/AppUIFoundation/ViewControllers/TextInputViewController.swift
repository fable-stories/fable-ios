//
//  TextInputViewController.swift
//  AppUIFoundation
//
//  Created by Andrew Aquino on 7/27/19.
//

import UIKit
import SnapKit
import AppFoundation
import ReactiveSwift

public protocol TextInputViewControllerConfiguration {
  var configuration: TextInputViewController.Configuration { get }
}

public class TextInputViewController: UIViewController {
  public struct Configuration: TextInputViewControllerConfiguration {
    
    public let title: Property<String>
    public let initialText: String?
    public let textAttributes: TextAttributes
    public let attributedPlaceholderText: NSAttributedString
    public let borderViewModel: BorderViewModelProtocol
    public let minimumTextViewInitialHeight: CGFloat
    
    public init(
      title: Property<String>,
      initialText: String?,
      textAttributes: TextAttributes,
      attributedPlaceholderText: NSAttributedString,
      borderViewModel: BorderViewModelProtocol,
      minimumTextViewInitialHeight: CGFloat = 36.0
    ) {
      self.title = title
      self.initialText = initialText
      self.textAttributes = textAttributes
      self.attributedPlaceholderText = attributedPlaceholderText
      self.borderViewModel = borderViewModel
      self.minimumTextViewInitialHeight = minimumTextViewInitialHeight
    }
    
    
    public var configuration: TextInputViewController.Configuration { return self }
  }

  public private(set) lazy var textView = PlaceholderTextView.new {
    $0.autocapitalizationType = .none
    $0.autocorrectionType = .no
    $0.returnKeyType = .done
    $0.attributedPlaceholderText = configuration.attributedPlaceholderText
    $0.font = configuration.textAttributes.font
    $0.textColor = configuration.textAttributes.textColor
    $0.text = configuration.initialText
    $0.delegate = self
  }

  private let configuration: Configuration
  
  public var onKeyReturn: ((String) -> Void)?

  public init(_ configuration: TextInputViewControllerConfiguration) {
    self.configuration = configuration.configuration
    super.init(nibName: nil, bundle: nil)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError()
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    configureSelf()
    configureLayout()
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    textView.becomeFirstResponder()
  }

  private func configureSelf() {
    view.backgroundColor = .white
    
    navigationItem.reactive.title <~ configuration.title
  }
  
  private func configureLayout() {
    view.layoutMargins = UIEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
    view.addSubview(textView)

    textView.snp.makeConstraints { make in
      make.top.equalTo(view.snp.topMargin)
      make.leading.equalTo(view.snp.leadingMargin)
      make.trailing.equalTo(view.snp.trailingMargin)
      make.height.greaterThanOrEqualTo(configuration.minimumTextViewInitialHeight)
    }
  }
  
  @discardableResult
  public override func resignFirstResponder() -> Bool {
    return textView.resignFirstResponder()
  }
}

extension TextInputViewController: UITextViewDelegate {
  public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if text == "\n" {
      textView.resignFirstResponder()
      self.onKeyReturn?(textView.text)
      return false
    }
    return true
  }
}
