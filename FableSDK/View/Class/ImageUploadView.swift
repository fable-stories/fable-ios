//
//  ImageUploadView.swift
//  FableSDKViews
//
//  Created by Andrew Aquino on 12/25/19.
//

import FableSDKUIFoundation
import SnapKit
import UIKit

public class ImageUploadView: UIButton {
  public let placeholderImageView = UIImageView()

  public init() {
    super.init(frame: .zero)

    imageView?.contentMode = .scaleAspectFill

    backgroundColor = .fablePlaceholderGray
    layer.cornerRadius = 12.0
    clipsToBounds = true

    placeholderImageView.image = UIImage(named: "cameraIcon")
    placeholderImageView.contentMode = .center

    addSubview(placeholderImageView)

    placeholderImageView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }

    if let imageView = self.imageView {
      imageView.reactive.producer(for: \UIImageView.image).take(duringLifetimeOf: self)
        .startWithValues { [weak self] image in
          self?.placeholderImageView.isHidden = image != nil
        }
    }
  }

  public required init?(coder: NSCoder) {
    fatalError()
  }
}
