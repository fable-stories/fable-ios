//
//  StorySectionViewHeader.swift
//  Fable
//
//  Created by Andrew Aquino on 8/26/19.
//

import FableSDKUIFoundation
import ReactiveSwift
import SnapKit
import UIKit

public class StorySectionViewHeader: UIView {
  public static let estimatedHeight: CGFloat = 36.0

  private let titleLabel = UILabel.create {
    $0.font = .fableFont(24.0, weight: .bold)
    $0.textColor = .fableBlack
  }

  private let subtitleLabel = UILabel.create {
    $0.font = .fableFont(12.0, weight: .semibold)
    $0.textColor = .fableDarkGray
  }

  private let contentView = UIView()

  private let title: String
  private let subtitle: String

  public init(title: String, subtitle: String) {
    self.title = title
    self.subtitle = subtitle
    super.init(frame: .zero)
    configureSelf()
    configureLayout()

    updateView()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  private func configureSelf() {
    backgroundColor = .clear
  }

  private func configureLayout() {
    addSubview(contentView)
    contentView.addSubview(titleLabel)
    contentView.addSubview(subtitleLabel)

    contentView.layoutMargins = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 8.0, right: 16.0)

    contentView.snp.makeConstraints { make in
      make.edges.equalTo(snp.edges)
      make.height.greaterThanOrEqualTo(StorySectionViewHeader.estimatedHeight)
    }

    titleLabel.snp.makeConstraints { make in
      make.top.equalTo(contentView.snp.topMargin)
      make.leading.equalTo(contentView.snp.leadingMargin)
      make.trailing.equalTo(contentView.snp.trailingMargin)
    }

    subtitleLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom)
      make.leading.equalTo(contentView.snp.leadingMargin)
      make.trailing.equalTo(contentView.snp.trailingMargin)
      make.bottom.equalTo(contentView.snp.bottomMargin)
    }
  }

  private func updateView() {
    titleLabel.text = title
    subtitleLabel.text = subtitle
  }
}
