//
//  PlaceholderTextView.swift
//  AppUIFoundation
//
//  Created by Andrew Aquino on 7/27/19.
//

import UIKit
import AppFoundation
import ReactiveSwift

open class PlaceholderTextView: UITextView {
  public private(set) lazy var placeholderTextView = UITextView(frame: .zero, textContainer: nil).also {
    $0.isUserInteractionEnabled = false
    $0.isScrollEnabled = false
    $0.backgroundColor = .clear
  }
  
  public override var text: String! {
    didSet {
      placeholderTextView.isHidden = text.isNotEmpty
    }
  }
  
  public override var attributedText: NSAttributedString! {
    didSet {
      placeholderTextView.isHidden = attributedText.string.isNotEmpty
    }
  }

  public var placeholderText: String? {
    get { return self.placeholderTextView.text }
    set { self.placeholderTextView.text = newValue }
  }

  public var attributedPlaceholderText: NSAttributedString? {
    get { return self.placeholderTextView.attributedText }
    set { self.placeholderTextView.attributedText = newValue }
  }

  public override var textContainerInset: UIEdgeInsets {
    didSet {
      placeholderTextView.textContainerInset = textContainerInset
    }
  }
  
  public override var font: UIFont? {
    didSet {
      placeholderTextView.font = font
    }
  }

  public init() {
    super.init(frame: .zero, textContainer: nil)
    configureSelf()
    configureLayout()
    configureReactive()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError()
  }
  
  private func configureSelf() {
    isScrollEnabled = false
  }
  
  private func configureLayout() {
    addSubview(placeholderTextView)
    placeholderTextView.snp.makeConstraints { make in
      make.edges.equalTo(snp.edges)
    }
  }
  
  private func configureReactive() {
    placeholderTextView.reactive.isHidden <~ reactive.continuousTextValues.map { !$0.isEmpty }
  }
}

extension Reactive where Base: TextInputViewController {
  public var continuousTextValues: Property<String> {
    return Property<String>(initial: "", then: base.textView.reactive.continuousTextValues)
  }
}
