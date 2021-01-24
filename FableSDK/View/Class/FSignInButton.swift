//
//  FSignInButton.swift
//  FableSDKUIFoundation
//
//  Created by Edmund Ng on 2020-05-28.
//

import UIKit

public enum SocialNetwork {
  case apple, google
}

public class SignInButton: UIButton {
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public convenience init(socialNetwork: SocialNetwork) {
    self.init(frame: CGRect(x: .zero, y: .zero, width: 292.0, height: 44.0))
    switch socialNetwork {
    case .apple:
      setImage(UIImage(named: "appleIcon"), for: .normal)
      setTitle("Sign in with Apple", for: .normal)
    case .google:
      setImage(UIImage(named: "googleIcon"), for: .normal)
      setTitle("Sign in with Google", for: .normal)
    }
    leftAlignButtonImage()
    applyConstraints()
  }

  private func configure() {
    titleLabel?.font = .fableFont(15.0, weight: .regular)
    setTitleColor(.black, for: .normal)

    layer.cornerRadius = 6.0
    layer.borderWidth = 0.2
    layer.borderColor = UIColor.fableDarkGray.cgColor
  }

  private func leftAlignButtonImage() {
    guard let imageViewWidth = imageView?.frame.width else { return }
    guard let titleLabelWidth = titleLabel?.intrinsicContentSize.width else { return }
    contentHorizontalAlignment = .left
    imageEdgeInsets = UIEdgeInsets(top: 0.0, left: 30.0 - imageViewWidth / 2, bottom: 0.0, right: 0.0)
    titleEdgeInsets = UIEdgeInsets(top: 0.0, left: (bounds.width - titleLabelWidth) / 2 - imageViewWidth, bottom: 0.0, right: 0.0)
  }

  private func applyConstraints() {
    snp.makeConstraints { make in
      make.width.equalTo(292.0)
      make.height.equalTo(44.0)
    }
  }
}
