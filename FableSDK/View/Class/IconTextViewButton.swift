//
//  IconTextViewButton.swift
//  FableSDKViews
//
//  Created by Andrew Aquino on 12/25/19.
//

import FableSDKUIFoundation
import Foundation
import SnapKit
import UIKit

public class IconTextViewButton: UIButton {
  public let iconImageView = UIImageView()
  public let textLabel = UILabel()
  public let textView = UITextView()
  public let chevron = UIImageView()

  public init(icon: UIImage?, title: String) {
    super.init(frame: .zero)

    addBorder(.bottom, viewModel: FableBorderViewModel.regular)

    layoutMargins = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)

    iconImageView.contentMode = .center
    iconImageView.image = icon
    iconImageView.tintColor = .fableBlack

    textLabel.font = .fableFont(16.0, weight: .light)
    textLabel.textColor = .fableBlack
    textLabel.text = title

    textView.font = .fableFont(16.0, weight: .light)
    textView.textColor = .fableTextGray
    textView.isScrollEnabled = false
    textView.isUserInteractionEnabled = false
    textView.textContainerInset = .zero

    chevron.contentMode = .center
    chevron.image = UIImage(named: "accessoryIcon")
    chevron.tintColor = .fableBlack

    addSubview(iconImageView)
    addSubview(textLabel)
    addSubview(textView)
    addSubview(chevron)

    iconImageView.snp.makeConstraints { make in
      make.centerX.equalTo(snp.leading).offset(24.0)
      make.centerY.equalTo(snp.top).offset(24.0)
    }

    textLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(40.0)
      make.trailing.equalToSuperview().inset(layoutMargins)
      make.centerY.equalTo(iconImageView.snp.centerY)
    }

    textView.snp.makeConstraints { make in
      make.leading.equalTo(textLabel).offset(-5.0)
      make.trailing.equalTo(chevron.snp.leading).offset(-8.0)
      make.top.equalTo(textLabel.snp.bottom).offset(8.0)
      make.bottom.equalToSuperview().inset(layoutMargins)
    }

    chevron.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(layoutMargins)
      make.centerY.equalToSuperview()
    }

    snp.makeConstraints { make in
      make.height.greaterThanOrEqualTo(60.0)
    }

    setContentHuggingPriority(.defaultHigh, for: .vertical)
    textLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    textView.setContentCompressionResistancePriority(.required, for: .vertical)
  }

  public required init?(coder: NSCoder) {
    fatalError()
  }

  override public func layoutIfNeeded() {
    super.layoutIfNeeded()
  }
}
