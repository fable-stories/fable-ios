//
//  CKModifierCollectionViewCell.swift
//  Fable
//
//  Created by Andrew Aquino on 12/1/19.
//

import AppFoundation
import FableSDKEnums
import FableSDKModelObjects
import ReactiveCocoa
import ReactiveSwift
import SnapKit
import UIKit

public class CKModifierCollectionViewCell: UICollectionViewCell {
  public struct ViewModel {
    public let modifierKind: ModifierKind
    public let title: String
  }

  public static let estimatedSize = CGSize(
    width: 10.0,
    height: 32.0
  )
  public static let contentInset = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)

  public let contentContainer = UIView()
  public let titleLabel = UILabel()

  public let mutableControlState = Property<UIControl.State>(value: .normal)

  public private(set) var viewModel: ViewModel?

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

    titleLabel.font = .fableFont(12.0, weight: .regular)
    titleLabel.textAlignment = .center
  }

  private func configureLayout() {
    contentView.addSubview(contentContainer)
    contentContainer.addSubview(titleLabel)

    contentContainer.layoutMargins = CharacterCollectionViewCell.contentInset
    contentContainer.snp.makeConstraints { make in
      make.edges.equalTo(contentView)
    }

    titleLabel.snp.makeConstraints { make in
      make.edges.equalTo(contentContainer).inset(contentContainer.layoutMargins)
    }
  }

  public func configure(viewModel: ViewModel) {
    self.viewModel = viewModel

    titleLabel.text = viewModel.title

    mutableControlState.producer
      .take(until: reactive.prepareForReuse).startWithValues { [weak self] controlState in
        guard let self = self else { return }
        switch controlState {
        case .normal:
          self.contentContainer.backgroundColor = .white
          self.titleLabel.textColor = .fableBlack
          self.contentContainer.layer.borderColor = UIColor.fableBlack.cgColor
        case .selected:
          self.contentContainer.backgroundColor = .fableRed
          self.titleLabel.textColor = .white
          self.contentContainer.layer.borderColor = UIColor.clear.cgColor
        default:
          break
        }
      }
  }
}
