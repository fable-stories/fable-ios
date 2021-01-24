//
//  LoginViewControllerEN.swift
//  AppFoundation
//
//  Created by Edmund Ng on 2020-05-28.
//

import AppUIFoundation
import AuthenticationServices
import FableSDKResolver
import FableSDKUIFoundation
import FableSDKModelManagers
import FableSDKEnums
import FableSDKViews
import FirebaseAuth
import Firebolt
import GoogleSignIn
import ReactiveCocoa
import ReactiveSwift
import UIKit

public protocol LoginViewControllerSocialDelegate: class {
  func loginViewController(dismissViewController viewController: LoginViewControllerSocial)
}

public class LoginViewControllerSocial: UIViewController {
  private let resolver: FBSDKResolver
  private let authManager: AuthManager
  private let analyticsManager: AnalyticsManager
  private let eventManager: EventManager
  
  public weak var delegate: LoginViewControllerSocialDelegate?

  public init(resolver: FBSDKResolver) {
    self.resolver = resolver
    self.authManager = resolver.get()
    self.analyticsManager = resolver.get()
    self.eventManager = resolver.get()
    super.init(nibName: nil, bundle: nil)
    view.backgroundColor = .white
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private lazy var logoImage: UIImageView = {
    var logoImage = UIImageView(image: UIImage(named: "fableLogo"))
    logoImage.contentMode = .scaleAspectFit
    return logoImage
  }()

  private lazy var logoText: UILabel = {
    var logoText = UILabel()
    logoText.text = "fable"
    logoText.font = .fableFont(40.0, weight: .regular)
    return logoText
  }()

  private lazy var fableLogo: UIStackView = {
    var fableLogo = UIStackView(arrangedSubviews: [logoImage, logoText])
    fableLogo.axis = .vertical
    fableLogo.spacing = 10.0
    fableLogo.alignment = .center
    return fableLogo
  }()

  private lazy var fableSignInMethods: UIStackView = {
    var fableSignInMethods = UIStackView()
    fableSignInMethods.axis = .vertical
    fableSignInMethods.spacing = 20.0
    var googleSignInButton = SignInButton(socialNetwork: .google)
    fableSignInMethods.addArrangedSubview(googleSignInButton)
    googleSignInButton.reactive.controlEvents(.touchUpInside).take(duringLifetimeOf: self).observeValues { [weak self] _ in
      guard let self = self else { return }
      self.analyticsManager.trackEvent(AnalyticsEvent.didSelectGoogleSignIn)
      self.authManager.presentGoogleAuthViewController(presentingController: self)
    }
    googleSignInButton.snp.makeConstraints { make in
      make.height.equalTo(40.0)
    }
    if #available(iOS 13.0, *) {
      let appleSignInButton = ASAuthorizationAppleIDButton()
      fableSignInMethods.addArrangedSubview(appleSignInButton)
      appleSignInButton.reactive.controlEvents(.touchUpInside).take(duringLifetimeOf: self).observeValues { [weak self] _ in
        guard let self = self else { return }
        self.analyticsManager.trackEvent(AnalyticsEvent.didSelectAppleSignIn)
        self.authManager.authenticateWithApple()
      }
      appleSignInButton.snp.makeConstraints { make in
        make.height.equalTo(40.0)
      }
    }
    let signInWithEmailButton = Button(FableButtonViewModel.plain())
    signInWithEmailButton.setTitle("Sign In with Email", for: .normal)
    signInWithEmailButton.reactive.controlEvents(.touchUpInside).observeValues { [weak self] _ in
      guard let self = self else { return }
      self.analyticsManager.trackEvent(AnalyticsEvent.didSelectEmailsignIn)
      let vc: LoginViewController = LoginViewController(resolver: self.resolver)
      let navVC = UINavigationController(rootViewController: vc)
      vc.navigationItem.leftBarButtonItem = .makeCloseButton(onSelect: { [weak vc] in
        vc?.dismiss(animated: true, completion: nil)
      })
      self.present(navVC, animated: true, completion: nil)
    }
    signInWithEmailButton.snp.makeConstraints { make in
      make.height.equalTo(40.0)
    }
    fableSignInMethods.addArrangedSubview(signInWithEmailButton)
    return fableSignInMethods
  }()

  override public func viewDidLoad() {
    super.viewDidLoad()
    layoutSubviews()
    configureReactive()
  }

  private func layoutSubviews() {
    view.addSubViews(logoImage, logoText)
    view.addSubViews(fableLogo, fableSignInMethods)

    logoImage.snp.makeConstraints { make in
      make.size.equalTo(CGSize(width: 82.0, height: 102.0))
    }
    logoText.snp.makeConstraints { make in
      make.size.equalTo(CGSize(width: 100.0, height: 41.0))
    }

    fableLogo.snp.makeConstraints { make in
      make.top.equalTo(view.snp.top).offset(162.0)
      make.centerX.equalTo(view.snp.centerX)
      make.size.equalTo(CGSize(width: 100.0, height: 155.0))
    }

    fableSignInMethods.snp.makeConstraints { make in
      make.top.equalTo(fableLogo.snp.bottom).offset(50.0)
      make.centerX.equalTo(view.snp.centerX)
      make.leading.equalTo(view.snp.leading).offset(40.0)
      make.trailing.equalTo(view.snp.leading).offset(-40.0)
    }
  }

  public func configureReactive() {
    self.fableSignInMethods.reactive.isUserInteractionEnabled <~ self.authManager.isAuthenticating.map { !$0 }
    self.eventManager.onEvent.sinkDisposed(receiveCompletion: nil) { [weak self] event in
      guard let self = self else { return }
      switch event {
      case AuthManagerEvent.userDidSignIn:
        self.delegate?.loginViewController(dismissViewController: self)
      default:
        break
      }
    }
  }
}
