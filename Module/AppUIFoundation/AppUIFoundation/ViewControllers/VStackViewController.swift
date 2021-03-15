//
//  VStackViewController.swift
//  AppUIFoundation
//
//  Created by Andrew Aquino on 9/21/19.
//

import UIKit
import SnapKit

public class VStackViewController: UIViewController {
  
  private let stackView = UIStackView.new {
    $0.axis = .vertical
    $0.alignment = .top
    $0.distribution = .fillProportionally
  }
  
  private let views: [UIView]
  
  public init(views: [UIView]) {
    self.views = views
    super.init(nibName: nil, bundle: nil)
  }
  
  public required init?(coder: NSCoder) {
    fatalError()
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    configureLayout()
  }
  
  private func configureLayout() {
    view.addSubview(stackView)
    
    stackView.snp.makeConstraints { make in
      make.edges.equalTo(view.snp.edges)
    }
  }
}
