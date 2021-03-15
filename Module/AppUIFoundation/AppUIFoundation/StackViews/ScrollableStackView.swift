//
//  ScrollableStackView.swift
//  AppUIFoundation
//
//  Created by Andrew Aquino on 12/18/19.
//

import UIKit
import SnapKit

public class ScrollableStackView: UIView {
  private let scrollView = UIScrollView()
  private let stackView = UIStackView.new {
    $0.axis = .vertical
    $0.distribution = .fillProportionally
    $0.alignment = .top
  }
  
  public init() {
    super.init(frame: .zero)
    addSubview(scrollView)
    
    stackView.setContentHuggingPriority(UILayoutPriority(rawValue: 0.0), for: .vertical)

    scrollView.snp.makeConstraints { make in
//      make.edges.equalToSuperview()
      make.width.equalToSuperview()
      make.height.equalToSuperview()
    }
    
    scrollView.addSubview(stackView)
    
    stackView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
      make.leading.equalToSuperview()
      make.width.equalToSuperview()
    }
  }
  
  public required init(coder: NSCoder) {
    fatalError()
  }
  
  public func addArrangedSubview(_ view: UIView) {
    self.stackView.addArrangedSubview(view)
  }
  
  public func addArrangedSubviews(_ views: [UIView]) {
    self.stackView.addArrangedSubviews(views)
  }
  
  public override func layoutIfNeeded() {
    super.layoutIfNeeded()
    stackView.layoutIfNeeded()
    for view in stackView.arrangedSubviews {
      view.layoutIfNeeded()
    }
  }
}
