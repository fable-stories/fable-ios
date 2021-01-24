//
//  CharacterCollectionViewCell.swift
//  Fable
//
//  Created by Andrew Aquino on 12/1/19.
//

import AppFoundation
import FableSDKModelObjects
import ReactiveCocoa
import ReactiveSwift
import SnapKit
import UIKit

public class CharacterCollectionViewCell: UICollectionViewCell {
  public static let estimatedSize = CGSize(
    width: 10.0,
    height: 32.0
  )
  public static let contentInset = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)

  public let contentContainer = UIView()
  public let nameLabel = UILabel()

  public let mutableControlState = Property<UIControl.State>(value: .normal)

  public private(set) var character: Character?

  public var onLongPress: VoidClosure?

  override public init(frame: CGRect) {
    super.init(frame: .zero)
    configureSelf()
    configureSubviews()
    configureLayout()
  }

  public required init?(coder: NSCoder) {
    fatalError()
  }

  private func configureSelf() {}

  private func configureSubviews() {
    contentContainer.layer.cornerRadius = 4.0
    contentContainer.layer.borderWidth = 1.0

    nameLabel.font = .fableFont(12.0, weight: .regular)
    nameLabel.textAlignment = .center
  }

  private func configureLayout() {
    contentView.addSubview(contentContainer)
    contentContainer.addSubview(nameLabel)

    contentContainer.layoutMargins = CharacterCollectionViewCell.contentInset
    contentContainer.snp.makeConstraints { make in
      make.edges.equalTo(contentView)
    }

    nameLabel.snp.makeConstraints { make in
      make.edges.equalTo(contentContainer).inset(contentContainer.layoutMargins)
    }

    let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(gesture:)))
    contentContainer.addGestureRecognizer(longPress)
  }

  public func configure(character: Character, controlState: UIControl.State) {
    self.character = character

    nameLabel.text = character.name

    guard let color: UIColor = character.color else { return }
    contentContainer.layer.borderColor = color.cgColor
    switch controlState {
    case .normal:
      contentContainer.backgroundColor = .white
      nameLabel.textColor = color
    case .selected:
      contentContainer.backgroundColor = color
      nameLabel.textColor = .white
    default:
      break
    }
  }

  @objc private func longPressed(gesture: UILongPressGestureRecognizer) {
    if case .began = gesture.state {
      onLongPress?()
    }
  }
}
