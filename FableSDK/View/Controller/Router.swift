//
//  Router.swift
//  Fable
//
//  Created by Andrew Aquino on 03/19/20.
//

import AppFoundation
import FableSDKResolver
import Firebolt
import UIKit


public class Router {
  private var _currentViewController: UIViewController?
  private var currentViewController: UIViewController {
    set { _currentViewController = newValue }
    get { _currentViewController ?? rootViewController }
  }

  private var currentNavigationController: UINavigationController? {
    (currentViewController as? UINavigationController)
      ?? currentViewController.navigationController
  }

  public var rootViewController: UIViewController!

  public init() {
    self.rootViewController = UIViewController()
  }

  public func presentLogin() {
    let vc: LoginViewController = get()
    vc.navigationItem.leftBarButtonItem = .makeCloseButton(onSelect: { [weak self] in
      self?.currentViewController.dismiss(animated: true, completion: nil)
    })

    vc.loginAction.values.take(first: 1).observeValues { [weak self] _ in
      guard let self = self else { return }
      self.currentViewController.dismiss(animated: true, completion: nil)
    }

    let navVC = UINavigationController(rootViewController: vc)

    currentNavigationController?.popViewController(animated: true)
    currentViewController.present(navVC, animated: true, completion: nil)
  }

  public func presentEditProfile() {
    let vc: EditUserProfileViewController = get()
    vc.navigationItem.leftBarButtonItem = .makeBackButton(onSelect: { [weak self] in
      self?.currentNavigationController?.popViewController(animated: true)
    })
    currentNavigationController?.pushViewController(vc, animated: true)
  }
}
