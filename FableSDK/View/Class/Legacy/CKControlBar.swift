//
//  CKControlBar.swift
//  Fable
//
//  Created by Andrew Aquino on 10/21/19.
//

import AppFoundation
import AppUIFoundation
import FableSDKEnums
import FableSDKUIFoundation
import ReactiveSwift
import SnapKit
import UIKit

public protocol CKControlBarDelegate: class {
  
  
}

public class CKControlBar: UIView {
  private static let height: CGFloat = 48.0

  public var onCharacterListSelect: VoidClosure?
  public var onEditButtonSelect: VoidClosure?
  public var onSendSelect: StringClosure?
  public var onChoiceBlockSelect: VoidClosure?

//  private let workspaceManager: WorkspaceManager
//  private let stateManager: StateManager

  public init() {
    super.init(frame: .zero)
    configureSelf()
    configureCharacterControlBar()
    configureLayout()
    configureReactive()
    configureReactiveDataModel()

//    self.workspaceManager.onUpdate.take(duringLifetimeOf: self).observeValues { [weak self] editEvents in
//      guard let self = self else { return }
//      for editEvent in editEvents {
//        switch editEvent {
//        case let .selectMessage(event):
//          if let messageId = event.messageId {
//            if let message = self.workspaceManager.fetchMessage(messageId: messageId) {
//              self.textView.text = message.text
//              self.textView.becomeFirstResponder()
//            }
//          } else {
//            DispatchQueue.main.async {
//              self.textView.text = ""
//            }
//          }
//        case let .messageInputCommand(event):
//          switch event.command {
//          case .becomeFirstResponder: self.textView.becomeFirstResponder()
//          case .resignFirstResponder: self.textView.resignFirstResponder()
//          case let .setText(text): self.textView.text = text
//          }
//        default:
//          break
//        }
//      }
//    }
  }

  public required init?(coder: NSCoder) {
    fatalError()
  }

  private let verticalControlStackView = UIStackView.create {
    $0.axis = .vertical
    $0.distribution = .fillProportionally
    $0.spacing = 4.0
  }
  
  private let topHorizontalStackView = UIStackView.create {
    $0.axis = .horizontal
    $0.distribution = .fillProportionally
    $0.spacing = 16.0
  }
  
  private lazy var characterControlBar = CharacterModifierControlBar()
  
  private lazy var moreButton: UIButton = .create {
    $0.setImage(UIImage(named: "sortIconGray")?.withRenderingMode(.alwaysTemplate), for: .normal)
    $0.tintColor = .fableBlack
    $0.imageView?.contentMode = .scaleAspectFit
    $0.reactive.pressed = .invoke { [weak self] in
      self?.onEditButtonSelect?()
    }
  }

  private let bottomControlView = UIView()

  private let rightControlStackView = UIStackView.create {
    $0.axis = .horizontal
    $0.distribution = .fillProportionally
    $0.spacing = 16.0
  }

  private lazy var choiceModifierButton = UIButton.create {
    $0.setImage(UIImage(named: "choiceGroupModifier"), for: .normal)
    $0.reactive.pressed = .invoke { [weak self] in
      self?.onChoiceBlockSelect?()
    }
    $0.isHidden = true
  }
  
  private lazy var textView = PlaceholderTextView.create {
    $0.isScrollEnabled = false
    $0.font = .fableFont(16.0, weight: .regular)
    $0.autocorrectionType = .yes
    $0.autocapitalizationType = .sentences
    $0.textColor = .fableBlack
    $0.returnKeyType = .default
    $0.backgroundColor = .clear
    $0.textContainerInset = UIEdgeInsets(top: 6.0, left: 4.0, bottom: 0.0, right: 0.0)
    $0.placeholderTextView.font = .fableFont(16.0, weight: .regular)
    $0.placeholderTextView.textColor = .fableBackgroundTextGray
    $0.placeholderText = "Enter message text"
    $0.accessibilityLabel = "Enter message text"
    $0.layer.borderColor = UIColor.fableLightGray.cgColor
    $0.layer.borderWidth = 1.0
    $0.layer.cornerRadius = 4.0
    $0.delegate = self
  }

  private lazy var sendButton = UIButton.create {
    $0.setImage(UIImage(named: "sendButtonRed"), for: .normal)
    $0.accessibilityLabel = "Send"
    $0.reactive.pressed = .invoke { [weak self] in
      guard let self = self else { return }
      self.onSendSelect?(self.textView.text)
    }
  }

  private func configureSelf() {
    backgroundColor = .white
  }

  private func configureCharacterControlBar() {
    characterControlBar.onCharacterListSelect = { [weak self] in
      self?.onCharacterListSelect?()
    }
  }

  private func configureLayout() {
    layoutMargins = UIEdgeInsets(top: 6.0, left: 12.0, bottom: 8.0, right: 12.0)

    addSubview(verticalControlStackView)
    verticalControlStackView.addArrangedSubview(topHorizontalStackView)
    topHorizontalStackView.addArrangedSubview(characterControlBar)
    topHorizontalStackView.addArrangedSubview(moreButton)
    
    moreButton.snp.makeConstraints { make in
      make.width.equalTo(24.0)
    }

    verticalControlStackView.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(layoutMargins)
    }

    verticalControlStackView.addArrangedSubview(bottomControlView)
    bottomControlView.addSubview(textView)
    bottomControlView.addSubview(rightControlStackView)
    rightControlStackView.addArrangedSubview(choiceModifierButton)
    rightControlStackView.addArrangedSubview(sendButton)
    
    bottomControlView.snp.makeConstraints { make in
      make.height.equalTo(40.0)
    }

    textView.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.trailing.equalTo(rightControlStackView.snp.leading).inset(-8.0)
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
    }

    rightControlStackView.snp.makeConstraints { make in
      make.trailing.equalToSuperview()
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
      make.height.equalTo(CKControlBar.height)
    }

    rightControlStackView.arrangedSubviews.forEach { view in
      view.snp.makeConstraints { make in
        make.width.equalTo(24.0)
        make.height.equalTo(24.0)
      }
    }
  }

  private func configureReactive() {}

  private func configureReactiveDataModel() {}
  
  public func updateCharacterControlBar() {
    characterControlBar.reloadData()
  }
}

extension CKControlBar: UITextViewDelegate {
  public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if text == "\n" { /// return key
      textView.resignFirstResponder()
      return false
    }
//    if let messageId = workspaceManager.selectedMessage?.messageId {
//      if text == "", textViewText.isNotEmpty {
//        if range.length == 0 {
//          textViewText.removeLast()
//        } else if let range = Range(range, in: textViewText) {
//          textViewText.replaceSubrange(range, with: "")
//        }
//
//        workspaceManager.addAndCommitEditEvent(.updateMessage(EditEvent.UpdateMessageEvent(
//          messageId: messageId,
//          text: textViewText
//        )))
//      } else {
//        workspaceManager.addAndCommitEditEvent(.updateMessage(EditEvent.UpdateMessageEvent(
//          messageId: messageId,
//          text: textViewText + text
//        )))
//      }
//    }
    return true
  }
}
