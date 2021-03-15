//
//  IconLabelView.swift
//  AppUIFoundation
//
//  Created by Andrew Aquino on 9/21/19.
//

import AppFoundation
import UIKit
import ReactiveSwift
import ReactiveCocoa
import SnapKit

public class IconLabelRowView: UIView {
  
  public static let size = CGSize(width: ScreenSize.width, height: 52.0)

  public let mutableIcon = MutableProperty<UIImage?>(nil)
  public let mutableTitle = MutableProperty<String>("")
  public let mutableInLineSubtitle = MutableProperty<String>("")
  public let mutableSubtitle = MutableProperty<String>("")
  
  public var onSelectAction: Action<Void, Void, Never>? {
    didSet {
      guard let onSelectAction = onSelectAction else {
        containerButton.reactive.pressed = nil
        return
      }
      containerButton.reactive.pressed = CocoaAction(onSelectAction)
    }
  }
  
  private let containerButton = UIButton()

  private let iconImageView = UIImageView.new {
    $0.contentMode = .scaleAspectFit
  }
  private let verticalStackView = UIStackView.new {
    $0.alignment = .top
    $0.axis = .vertical
    $0.distribution = .fillProportionally
  }
  private let inLineStackView = UIStackView.new {
    $0.alignment = .trailing
    $0.axis = .horizontal
    $0.distribution = .fillProportionally
  }
  private let titleLabel = UILabel.new {
    $0.numberOfLines = 0
  }
  private let inLineSubtitleLabel = UILabel.new {
    $0.numberOfLines = 0
  }
  private let subtitleTextView = UITextView.new {
    $0.textContainerInset = .zero
    $0.isScrollEnabled = false
  }
  private let chevronImageView = UIImageView()
  
  public init() {
    super.init(frame: .zero)
    configureSelf()
    configureLayout()
    configureReactive()
  }
  
  public required init?(coder: NSCoder) {
    fatalError()
  }
  
  private func configureSelf() {
    
  }
  
  private func configureLayout() {
    layoutMargins = UIEdgeInsets(top: 16.0, left: 14.0, bottom: 16.0, right: 14.0)
    
    addSubview(containerButton)
    addSubview(iconImageView)

    addSubview(inLineStackView)
    inLineStackView.addArrangedSubview(titleLabel)
    inLineStackView.addArrangedSubview(inLineSubtitleLabel)
    inLineStackView.addArrangedSubview(chevronImageView)
    
    verticalStackView.addArrangedSubview(inLineStackView)
    verticalStackView.addArrangedSubview(subtitleTextView)

    containerButton.snp.makeConstraints { make in
      make.edges.equalTo(snp.edges)
    }

    iconImageView.snp.makeConstraints { make in
      make.leading.equalTo(snp.leadingMargin)
      make.width.equalTo(16.0)
      make.height.equalTo(16.0)
      make.centerY.equalTo(snp.centerY)
    }
    
    verticalStackView.snp.makeConstraints { make in
      make.leading.equalTo(iconImageView.snp.trailing)
      make.trailing.equalTo(snp.trailingMargin)
      make.top.equalTo(snp.topMargin)
      make.bottom.equalTo(snp.bottomMargin)
    }
    
    inLineStackView.snp.makeConstraints { make in
      make.width.equalTo(verticalStackView.snp.width)
    }
  }
  
  private func configureReactive() {
    iconImageView.reactive.image <~ mutableIcon
    titleLabel.reactive.text <~ mutableTitle
    inLineSubtitleLabel.reactive.text <~ mutableInLineSubtitle
    subtitleTextView.reactive.text <~ mutableSubtitle
  }
}

