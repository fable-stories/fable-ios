//
//  UIViewController+Extensions.swift
//  Fable
//
//  Created by Andrew Aquino on 4/9/19.
//

import UIKit
import ReactiveSwift
import AppFoundation

extension UIViewController {
  public func presentAlert(title: String? = nil, body: String, onComplete: VoidClosure? = nil) {
    let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { [weak alert] _ in
      alert?.dismiss(animated: true, completion: onComplete)
    }))
    present(alert, animated: true, completion: onComplete)
  }
  
  public func presentAlert(error: Error?, onComplete: VoidClosure? = nil) {
    guard let error = error else { return }
    presentAlert(
      title: (error as? Exception)?.failureReason ?? "Error",
      body: (error as? Exception)?.description ?? error.localizedDescription,
      onComplete: onComplete
    )
  }
}
