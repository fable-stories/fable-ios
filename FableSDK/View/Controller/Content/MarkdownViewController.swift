//
//  MarkdownViewController.swift
//  FableSDKViewControllers
//
//  Created by Enrique Florencio on 8/3/20.
//

import Foundation
import AppUIFoundation
import FableSDKResolver
import FableSDKUIFoundation
import FableSDKViewPresenters
import FableSDKViews
import SnapKit
import UIKit
import Down

public struct MarkdownViewModel {
  public init(
    initialString: String,
    navigationTitle: String,
    actionButton: UIButton? = nil,
    configureTextView: ((UITextView) -> ())? = nil
  ) {
    self.initialString = initialString
    self.navigationTitle = navigationTitle
    self.actionButton = actionButton
    self.configureTextView = configureTextView
  }
  
  /// The Terms of Service text that will be turned into Markdown text
  public let initialString: String
  /// The title for the View Controller
  public let navigationTitle: String
  public let actionButton: UIButton?
  public let configureTextView: ((UITextView) -> ())?
}

class MarkdownViewController: UIViewController, UITextViewDelegate {
  
  private let viewModel: MarkdownViewModel
  
  /// The textview that will display the Markdown text
  private let markdownText = UITextView()
  
  /// Initialize the Terms of Service string and title for the view controller
  public init(
    viewModel: MarkdownViewModel
  ) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    if let configureTextView = viewModel.configureTextView {
      configureTextView(markdownText)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    /// Set the textview delegate to this view controller
    self.markdownText.delegate = self
    /// Configure the layout for the view
    configureLayout()
    ///Configure the layout for the markDown text
    configureSelf()
  }
  
  func configureSelf() {
    /// Set the title of the view controller equal to the one passed into the init method
    navigationItem.title = viewModel.navigationTitle
    view.backgroundColor = .fableWhite
    markdownText.backgroundColor = .fableWhite
    view.addSubview(markdownText)
    /// Set the constraints for the UITextView
    markdownText.snp.makeConstraints { (make) in
      make.top.equalTo(view.snp.top).inset(12)
      make.leading.equalTo(view.snp.leading).inset(16)
      make.trailing.equalTo(view.snp.trailing).inset(16)
      make.bottom.equalTo(view.snp.bottom)
    }
    
    if let actionButton = viewModel.actionButton {
      view.addSubview(actionButton)
      actionButton.snp.makeConstraints { make in
        make.height.equalTo(44.0)
        make.leading.equalToSuperview().offset(16.0)
        make.trailing.equalToSuperview().offset(-16.0)
        make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-12.0)
      }
      self.markdownText.contentInset = .init(top: 0.0, left: 0.0, bottom: 64.0, right: 0.0)
    }

    /// Convert the Terms of Service string into markdown code.
    let down = Down(markdownString: viewModel.initialString)
    
    /// If we can't turn the markdown code into an attributed string then there is something fundamentally wrong with the program.
    guard let convertedText = try? down.toAttributedString() else {
      fatalError()
    }
    
    /// Set the UITextView attributed text to the markdown text
    markdownText.attributedText = convertedText
  }
  
  func configureLayout() {
    view.layoutMargins = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 20.0, right: 16.0)
    
  }
}

