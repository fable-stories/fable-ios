//
//  ChoiceRowView.swift
//  Fable
//
//  Created by Andrew Aquino on 10/11/19.
//

import AppFoundation
import FableSDKModelObjects
import ReactiveFoundation
import ReactiveSwift
import SnapKit
import UIKit

public class ChoiceRowView: UIView {
  public enum NodeKind {
    case none
    case path
    case current
  }

  public var choice: Choice? {
    didSet {
      guard let choice = choice else { return }
      updateView(choice: choice)
      updateReactive(choice: choice)
    }
  }

  public var onSelect: VoidClosure?
  public var goToMessageGroupId: ((String) -> Void)?

  public init(_ initialValue: Choice?) {
    super.init(frame: .zero)
    configureSelf()
    configureLayout()
    configureGestures()

    self.choice = initialValue
  }

  public required init?(coder: NSCoder) {
    fatalError()
  }

  private let contentView = UIView()

  private lazy var titleTextField = UITextField.create {
    $0.font = .fableFont(13.0, weight: .light)
    $0.isUserInteractionEnabled = false
    $0.returnKeyType = .done
    $0.delegate = self
  }

  private lazy var editButton = UIButton.create {
    $0.setImage(UIImage(named: "editIconBlack")?.withRenderingMode(.alwaysTemplate), for: .normal)
    $0.isHidden = true
    $0.reactive.pressed = .invoke { [weak self] in
      self?.titleTextField.isUserInteractionEnabled = true
      self?.titleTextField.becomeFirstResponder()
    }
  }

  private lazy var goToButton = UIButton.create {
    $0.setImage(UIImage(named: "storyMapFlag")?.withRenderingMode(.alwaysTemplate), for: .normal)
//    $0.reactive.pressed = .invoke { [weak self] in
//      guard let mcId = self?.choice?.mutableTargetMessageGroupId.value else { return }
//      self?.goToMessageGroupId?(mcId)
//    }
  }

  private func configureSelf() {}

  private func configureLayout() {
    layoutMargins = .zero
    contentView.layoutMargins = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 12.0)

    addSubview(contentView)
    contentView.addSubview(titleTextField)

    contentView.snp.makeConstraints { make in
      make.edges.equalTo(snp.edges)
      make.height.equalTo(50.0)
    }

    titleTextField.snp.makeConstraints { make in
      make.leading.equalTo(contentView.snp.leadingMargin)
      make.trailing.equalTo(contentView.snp.trailingMargin)
      make.top.equalTo(contentView.snp.topMargin)
      make.bottom.equalTo(contentView.snp.bottomMargin)
    }
  }

  private func configureGestures() {
    let tapGesture = UITapGestureRecognizer()
    tapGesture.reactive.recognized().take(duringLifetimeOf: self).observeValues { [weak self] in
      self?.onSelect?()
    }
    contentView.addGestureRecognizer(tapGesture)
  }

  private func updateView(choice: Choice) {
    titleTextField.text = choice.choiceText
  }

  private func updateReactive(choice: Choice) {}

  // MARK: - View Updates

  public func setSelected(nodeKind: NodeKind) {
    switch nodeKind {
    case .none:
      contentView.backgroundColor = .white
      titleTextField.textColor = .fableMediumGray
      editButton.tintColor = .fableGray
      goToButton.tintColor = .fableGray
      editButton.isHidden = true
    case .path:
      contentView.backgroundColor = .white
      titleTextField.textColor = .fableBlack
      editButton.tintColor = .fableRed
      goToButton.tintColor = .fableRed
      editButton.isHidden = true
    case .current:
      contentView.backgroundColor = .fableRed
      titleTextField.textColor = .white
      editButton.tintColor = .white
      goToButton.tintColor = .white
      editButton.isHidden = false
    }
  }
}

extension ChoiceRowView: UITextFieldDelegate {
  public func textFieldDidBeginEditing(_ textField: UITextField) {}

  public func textFieldDidEndEditing(_ textField: UITextField) {
    textField.isUserInteractionEnabled = false
  }

  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
