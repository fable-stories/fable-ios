//
//  RootViewController.swift
//  StripeManager
//
//  Created by Andrew Aquino on 3/3/19.
//

import Foundation
import UIKit

public class RootViewController: UIViewController {
  
  private let stripeManager: StripeManagerProtocol = StripeManager()
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
  }
}
