//
//  StoryHorizontalDetailView.swift
//  Fable
//
//  Created by Andrew Aquino on 10/1/19.
//

import AppFoundation
import FableSDKModelObjects
import FableSDKUIFoundation
import Kingfisher
import ReactiveSwift
import SnapKit
import UIKit

public class StoryHorizontalDetailView: UIView {
  private static let verticalContentPadding: CGFloat = 0.0
  public static let defaultHeight: CGFloat = 175.0

  public var story: Story? {
    didSet {
      updateView()
    }
  }

  public init() {
    super.init(frame: .zero)
    configureSelf()
    configureLayout()
  }

  public required init?(coder: NSCoder) {
    fatalError()
  }

  private let storyImageView = UIImageView.create {
    $0.layer.cornerRadius = 12.0
    $0.clipsToBounds = true
  }

  private let titleLabel = UILabel.create {
    $0.numberOfLines = 2
    $0.font = .fableFont(13.0, weight: .medium)
    $0.textColor = .fableBlack
    $0.textAlignment = .left
  }

  private let authorLabel = UILabel.create {
    $0.numberOfLines = 1
    $0.font = .fableFont(13.0, weight: .regular)
    $0.textColor = .fableTextGray
    $0.textAlignment = .left
  }

  private let viewsLabel = UILabel.create {
    $0.numberOfLines = 1
    $0.font = .fableFont(11.0, weight: .regular)
    $0.textColor = .fableRed
    $0.textAlignment = .left
  }

  private let summaryTextView = UITextView.create {
    $0.isScrollEnabled = false
    $0.isUserInteractionEnabled = false
    $0.font = .fableFont(13.0, weight: .regular)
    $0.textColor = .fableTextGray
    $0.textAlignment = .left
    $0.textContainerInset = .zero
    $0.textContainer.lineBreakMode = .byTruncatingTail
    $0.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
  }

  private func configureSelf() {}

  private func configureLayout() {
    layoutMargins = UIEdgeInsets(top: 10.0, left: 16.0, bottom: 10.0, right: 16.0)

    addSubview(storyImageView)
    addSubview(titleLabel)
    addSubview(authorLabel)
    addSubview(viewsLabel)
    addSubview(summaryTextView)

    storyImageView.snp.makeConstraints { make in
      make.leading.equalTo(snp.leadingMargin)
      make.trailing.equalTo(snp.centerX).offset(-16.0)
      make.top.equalTo(snp.topMargin)
      make.height.equalTo(storyImageView.snp.width)
    }

    titleLabel.snp.makeConstraints { make in
      make.top.equalTo(snp.topMargin).offset(4.0)
      make.leading.equalTo(snp.centerX)
      make.trailing.equalTo(snp.trailingMargin)
    }

    authorLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom)
        .offset(StoryHorizontalDetailView.verticalContentPadding)
      make.leading.equalTo(snp.centerX)
      make.trailing.equalTo(snp.trailingMargin)
    }

    viewsLabel.snp.makeConstraints { make in
      make.top.equalTo(authorLabel.snp.bottom)
        .offset(StoryHorizontalDetailView.verticalContentPadding)
      make.leading.equalTo(snp.centerX)
      make.trailing.equalTo(snp.trailingMargin)
      make.height.equalTo(16.0)
    }

    summaryTextView.snp.makeConstraints { make in
      make.top.equalTo(viewsLabel.snp.bottom)
        .offset(StoryHorizontalDetailView.verticalContentPadding + 1.0)
      make.leading.equalTo(snp.centerX).offset(-5.0)
      make.trailing.equalTo(snp.trailingMargin).offset(5.0)
      make.bottom.equalTo(snp.bottomMargin).offset(-5.0)
    }
  }

  private func updateView() {
//    storyImageView.kf.setImage(with: story?.squareImageUrl)
    titleLabel.text = story?.title
    authorLabel.text = story?.userId.description
    summaryTextView.text = story?.synopsis

    layoutIfNeeded()
  }
}
