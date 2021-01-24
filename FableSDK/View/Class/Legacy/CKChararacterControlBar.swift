//
//  CKChararacterControlBar.swift
//  Fable
//
//  Created by Andrew Aquino on 12/5/19.
//

import SnapKit
import UIKit

public class CKChararacterControlBar: UIView {
  public init() {
    super.init(frame: .zero)
    configureSelf()
  }

  public required init?(coder: NSCoder) {
    fatalError()
  }

  private func configureSelf() {
    backgroundColor = .red
    snp.makeConstraints { make in
      make.height.equalTo(44.0)
    }
  }
}
