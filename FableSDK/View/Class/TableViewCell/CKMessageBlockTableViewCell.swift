//
//  MessageBlockTableViewCell.swift
//  Fable
//
//  Created by Andrew Aquino on 11/16/19.
//

import AppFoundation
import AppUIFoundation
import FableSDKEnums
import FableSDKModelObjects
import FableSDKUIFoundation
import ReactiveSwift
import SnapKit
import UIKit

public class MessageBlockTableViewCell: UITableViewCell {
  public static let height: CGFloat = 40.0

  public private(set) var message: Message?
  private var modifiers: Property<[BaseModifierProtocol]>?

  public private(set) var controlState: UIControl.State = .normal

  public var onBeginEdit: ((UITextView) -> Void)?
  public var onEndEdit: ((UITextView) -> Void)?
  public var onKeyReturn: ((UITextView) -> Void)?

  override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    configureSelf()
    configureSubviews()
    configureLayout()
    configureReactive()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  private let blockContainerView = UIView()
  private let blockContentStackView = UIStackView.new {
    $0.distribution = .fillProportionally
    $0.alignment = .fill
    $0.axis = .vertical
  }

  private let button = UIButton.new {
    $0.setImage(UIImage(named: "moreButtonGray"), for: .normal)
  }

  public let titleLabel = UITextView.new {
    $0.isScrollEnabled = false
    $0.font = .fableFont(13.0, weight: .semibold)
    $0.autocorrectionType = .no
    $0.tintColor = .fableBlack
    $0.backgroundColor = .clear
    $0.textContainerInset = .zero
    $0.isUserInteractionEnabled = false
  }

  public let textView = PlaceholderTextView.new {
    $0.isScrollEnabled = false
    $0.isUserInteractionEnabled = false
    $0.font = .fableFont(16.0, weight: .regular)
    $0.autocorrectionType = .yes
    $0.autocapitalizationType = .sentences
    $0.textColor = .fableBlack
    $0.returnKeyType = .done
    $0.backgroundColor = .clear
    $0.textContainerInset = .zero
    $0.placeholderTextView.font = .fableFont(16.0, weight: .regular)
    $0.placeholderTextView.textColor = .fableBackgroundTextGray
    $0.placeholderText = "Enter message text"
    $0.accessibilityLabel = "Enter message text"
  }

  private var blockerContainerViewLeadingConstraint: Constraint!
  private var blockerContainerViewTrailingConstraint: Constraint!

  private func configureSelf() {
    selectionStyle = .none

    blockContainerView.backgroundColor = .white
    blockContainerView.addBorder(.all, viewModel: FableBorderViewModel.regular)
    blockContainerView.layer.cornerRadius = 8.0
  }

  private func configureSubviews() {
    textView.delegate = self
  }

  private func configureLayout() {
    layoutMargins = .zero
    contentView.layoutMargins = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 0.0, right: 16.0)
    blockContainerView.layoutMargins = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 14.0)

    contentView.addSubview(blockContainerView)

    blockContentStackView.addArrangedSubview(titleLabel)
    blockContentStackView.addArrangedSubview(textView)
    blockContainerView.addSubview(blockContentStackView)

    blockContainerView.snp.makeConstraints { make in
      make.height.greaterThanOrEqualTo(MessageBlockTableViewCell.height)
      make.top.equalToSuperview().inset(contentView.layoutMargins)
      make.bottom.equalToSuperview().inset(contentView.layoutMargins)
      blockerContainerViewLeadingConstraint = make.leading.equalToSuperview()
        .constraint
      blockerContainerViewTrailingConstraint = make.trailing.equalToSuperview()
        .constraint
    }

    titleLabel.snp.makeConstraints { make in
      make.height.equalTo(20.0)
    }

    blockContentStackView.snp.makeConstraints { make in
      make.edges.equalTo(blockContainerView).inset(blockContainerView.layoutMargins)
    }
  }

  private func configureReactive() {
    textView.reactive.continuousTextValues.take(duringLifetimeOf: self).observeValues { [weak self] text in
      guard let self = self, let message = self.message else { return }
      self.message = message.copy(text: text)
    }
  }

  public func configure(
    message: Message?,
    controlState: UIControl.State,
    model: CKModelReadOnly
  ) {
    self.message = message
    self.controlState = controlState
    update()
  }
  
  private func update() {
    guard let message = message else { return }
    
    textView.text = message.text
    
    if let character = message.character {
      titleLabel.text = character.name
      titleLabel.textColor = .white
      titleLabel.isHidden = false
      textView.textColor = .white
      textView.tintColor = .white
      textView.placeholderTextView.textColor = UIColor.white.withAlphaComponent(0.5)
      blockContainerView.backgroundColor = character.color
      blockContainerView.layer.borderColor = UIColor.clear.cgColor
      
      switch character.messageAlignment {
      case .leading:
        blockerContainerViewLeadingConstraint.update(inset: contentView.layoutMargins.left - 8.0)
        blockerContainerViewTrailingConstraint.update(inset: contentView.layoutMargins.right + 8.0)
      case .trailing:
        blockerContainerViewLeadingConstraint.update(inset: contentView.layoutMargins.left + 8.0)
        blockerContainerViewTrailingConstraint.update(inset: contentView.layoutMargins.right - 8.0)
      case .center:
        blockerContainerViewLeadingConstraint.update(inset: contentView.layoutMargins.left)
        blockerContainerViewTrailingConstraint.update(inset: contentView.layoutMargins.right)
      }
    } else {
      titleLabel.isHidden = true
      titleLabel.textColor = .fableBlack
      textView.textColor = .fableBlack
      textView.tintColor = .fableBlack
      textView.placeholderTextView.textColor = .fableBackgroundTextGray
      blockContainerView.backgroundColor = .white
      blockContainerView.layer.borderColor = FableBorderViewModel.regular.viewModel.color.cgColor
      
      blockerContainerViewLeadingConstraint.update(inset: contentView.layoutMargins.left)
      blockerContainerViewTrailingConstraint.update(inset: contentView.layoutMargins.right)
    }
    
    if case .focused = controlState {
      self.blockContainerView.layer.borderColor = UIColor.fableBlack.withAlphaComponent(1.0).cgColor
    } else {
      self.blockContainerView.addBorder(.all, viewModel: FableBorderViewModel.regular)
    }
  }

  override public func becomeFirstResponder() -> Bool {
    textView.becomeFirstResponder()
  }

  override public func prepareForReuse() {
    super.prepareForReuse()
    message = nil
    modifiers = nil
  }
}

extension MessageBlockTableViewCell: UITextViewDelegate {
  public func textViewDidBeginEditing(_ textView: UITextView) {
    textView.isScrollEnabled = true
    controlState = .focused
    onBeginEdit?(textView)
  }

  public func textViewDidEndEditing(_ textView: UITextView) {
    textView.isScrollEnabled = false
    controlState = .normal
    onEndEdit?(textView)
  }

  public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if text == "\n" {
      textView.resignFirstResponder()
      onKeyReturn?(textView)
      return false
    }
    return true
  }
}
