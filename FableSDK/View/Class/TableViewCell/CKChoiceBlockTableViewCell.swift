//
//  ChoiceGroupTableViewCell.swift
//  Fable
//
//  Created by Andrew Aquino on 11/16/19.
//

import AppFoundation
import AppUIFoundation
import FableSDKEnums
import FableSDKModelObjects
import FableSDKUIFoundation
import FableSDKViewInterfaces
import UIKit

public class ChoiceGroupTableViewCell: UITableViewCell, ChoiceGroupTableViewCellProtocol {
  public static let estimatedHeight: CGFloat = 100.0

  public private(set) var message: Message?

  private weak var delegate: ChoiceGroupTableViewCellDelegate?

  override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    configureSelf()
    configureLayout()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  private let blockContainerView = UIView()
  private let horizontalContentStackView = UIStackView.create {
    $0.axis = .horizontal
    $0.spacing = 10.0
  }

  private let contentStackView = UIStackView.create {
    $0.axis = .vertical
    $0.spacing = 10.0
    $0.distribution = .equalSpacing
  }

  private let button = UIButton.create {
    $0.setImage(UIImage(named: "moreButtonGray"), for: .normal)
  }

  private func configureSelf() {
    selectionStyle = .none

    blockContainerView.backgroundColor = .white
    blockContainerView.addBorder(.all, viewModel: FableBorderViewModel.regular)
    blockContainerView.layer.cornerRadius = 16.0
  }

  private func configureLayout() {
    layoutMargins = .zero
    contentView.layoutMargins = UIEdgeInsets(top: 8.0, left: 12.0, bottom: 0.0, right: 12.0)
    blockContainerView.layoutMargins = UIEdgeInsets(top: 10.0, left: 14.0, bottom: 10.0, right: 14.0)

    contentView.addSubview(blockContainerView)
    blockContainerView.addSubview(horizontalContentStackView)
    horizontalContentStackView.addArrangedSubview(contentStackView)

    blockContainerView.snp.makeConstraints { make in
      make.height.greaterThanOrEqualTo(ChoiceGroupTableViewCell.estimatedHeight)
      make.edges.equalTo(contentView.snp.edges).inset(contentView.layoutMargins)
    }

    horizontalContentStackView.snp.makeConstraints { make in
      make.edges.equalTo(blockContainerView.snp.edges)
        .inset(blockContainerView.layoutMargins)
    }

//    button.snp.makeConstraints { make in
//      make.centerY.equalTo(blockContainerView.snp.centerY)
//      make.trailing.equalTo(blockContainerView.snp.trailingMargin)
//      make.width.equalTo(18.0)
//      make.height.equalTo(18.0)
//    }
//
//    contentStackView.snp.makeConstraints { make in
//      make.leading.equalTo(blockContainerView).inset(blockContainerView.layoutMargins)
//      make.top.equalTo(blockContainerView).inset(blockContainerView.layoutMargins)
//      make.bottom.equalTo(blockContainerView).inset(blockContainerView.layoutMargins)
//      make.trailing.equalTo(button.snp.leading).offset(-10.0)
//    }
  }

  public func configure(
    message: Message,
    delegate: ChoiceGroupTableViewCellDelegate
  ) {
    self.message = message
    self.delegate = delegate
    update()
  }

  private func update() {
    guard let delegate = delegate else { return }
    guard let message = message else { return }
    guard let choices = message.choiceGroup?.choices else { return }
    let choiceViews = choices.map { choice -> ChoiceRowContainer in
      let view = ChoiceRowContainer(
        choice: choice,
        controlState: delegate.choiceGroupTableViewCell(
          controlStateForChoice: choice.choiceId,
          cell: self
        ),
        delegate: delegate
      )
      return view
    }
    contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    contentStackView.addArrangedSubviews(choiceViews)
    layoutIfNeeded()
  }
}

public class ChoiceRowContainer: UIView, ChoiceRowViewProtocol {
  public let choice: Choice
  public let controlState: UIControl.State

  public weak var delegate: ChoiceRowViewDelegate?

  public init(choice: Choice, controlState: UIControl.State, delegate: ChoiceRowViewDelegate) {
    self.choice = choice
    self.controlState = controlState
    self.delegate = delegate
    super.init(frame: .zero)
    configureSelf()
    configureLayout()
    updateView()
  }

  public required init?(coder: NSCoder) {
    fatalError()
  }

  public let textView = PlaceholderTextView.create {
    $0.font = .fableFont(13.0, weight: .regular)
    $0.textAlignment = .left
    $0.returnKeyType = .done
    $0.isScrollEnabled = false
    $0.contentInset = .zero
    $0.placeholderText = "Enter choice description"
    $0.accessibilityLabel = "Enter choice description"
    $0.isUserInteractionEnabled = false
    $0.placeholderTextView.textColor = .fablePlaceholderGray
  }

  private func configureSelf() {
    layer.cornerRadius = 20.0
    addBorder(.all, viewModel: FableBorderViewModel.regular)
    textView.delegate = self
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
  }

  private func configureLayout() {
    layoutMargins = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
    addSubview(textView)

    textView.snp.makeConstraints { make in
      make.top.greaterThanOrEqualToSuperview()
      make.bottom.lessThanOrEqualToSuperview()
      make.leading.equalToSuperview().inset(layoutMargins)
      make.trailing.equalToSuperview().inset(layoutMargins)
      make.centerY.equalToSuperview()
    }

    snp.makeConstraints { make in
      make.height.greaterThanOrEqualTo(40.0)
    }
  }

  private func updateView() {
    textView.text = choice.choiceText
    switch controlState {
    case .highlighted:
      layer.borderColor = UIColor.fableBlack.cgColor
      textView.isUserInteractionEnabled = true
    default:
      layer.borderColor = FableBorderViewModel.regular.viewModel.color.cgColor
      textView.isUserInteractionEnabled = false
    }
  }

  @discardableResult
  override public func becomeFirstResponder() -> Bool {
    textView.becomeFirstResponder()
  }

  @discardableResult
  override public func resignFirstResponder() -> Bool {
    textView.resignFirstResponder()
  }

  @objc private func tapped() {
    delegate?.choiceRowView(choiceSelected: choice.choiceId, cell: self)
  }
}

extension ChoiceRowContainer: UITextViewDelegate {
  public func textViewDidBeginEditing(_ textView: UITextView) {
    textView.isScrollEnabled = true
    delegate?.choiceRowView(textViewEditEvent: .onBegan, for: choice.choiceId, cell: self)
  }

  public func textViewDidEndEditing(_ textView: UITextView) {
    textView.isScrollEnabled = false
    textView.isUserInteractionEnabled = false
    delegate?.choiceRowView(textViewEditEvent: .onEnded, for: choice.choiceId, cell: self)
  }

  public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if text == "\n" {
      textView.resignFirstResponder()
      delegate?.choiceRowView(textViewEditEvent: .onReturn, for: choice.choiceId, cell: self)
      return false
    }
    return true
  }
}
