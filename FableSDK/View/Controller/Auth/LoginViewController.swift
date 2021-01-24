//
//  LoginViewController.swift
//  AppFoundation
//
//  Created by Andrew Aquino on 3/27/19.
//

import AppFoundation
import AppUIFoundation
import AuthenticationServices
import FableSDKErrorObjects
import FableSDKResolver
import FableSDKModelObjects
import FableSDKModelManagers
import FableSDKUIFoundation
import ReactiveCocoa
import ReactiveSwift
import SnapKit
import UIKit

// https://stackoverflow.com/questions/5301305/animate-uilabel-text-between-two-numbers


public class LoginViewController: UIViewController {
  private enum LoginState: Equatable {
    case signIn
    case signUp
  }

  private let resolver: FBSDKResolver
  private let authManager: AuthManager
  
  public init(
    resolver: FBSDKResolver
  ) {
    self.resolver = resolver
    self.authManager = resolver.get()
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  private let mutableEmail = MutableProperty<String?>(nil)
  private let mutablePassword = MutableProperty<String?>(nil)

  public private(set) lazy var loginAction = Action<Void, Int, SignInError> { [weak self] in
    guard let self = self, let email = self.mutableEmail.value, let password = self.mutablePassword.value else {
      return .empty
    }
    return self.authManager.authenticate(
      email: email,
      password: password
    )
  }

  private lazy var transitionAction = Action<Void, Void, Never> { [weak self] in
    if let self = self {
      switch self.mutableLoginState.value {
      case .signIn: self.mutableLoginState.value = .signUp
      case .signUp: self.mutableLoginState.value = .signIn
      }
    }
    return .empty
  }

  private let mutableLoginState = MutableProperty<LoginState>(.signUp)

  private let titleLabel = UILabel()

  private let textFieldStackView = UIStackView()
  private let emailTextField = TextField("Email", configuration: .email)
  private let passwordTextField = TextField("Password", configuration: .password)

  private let actionButton = Button(FableButtonViewModel.action())
  private let signInWithSocialButton = Button(FableButtonViewModel.plain())
  private let transitionButton = Button(FableButtonViewModel.plainUnderline())

  override public func viewDidLoad() {
    super.viewDidLoad()
    configureSelf()
    configureSubviews()
    configureLayout()
    configureReactive()

    if envBool("debug") == true {
      emailTextField.text = "andrewaquino118@gmail.com"
      mutableEmail.value = emailTextField.text
      passwordTextField.text = "password"
      mutablePassword.value = passwordTextField.text
    }
  }

  private func configureSelf() {
    view.backgroundColor = .white

    navigationItem.title = "Login"
    navigationItem.isAccessibilityElement = true
    navigationItem.accessibilityLabel = "login"
  }

  private func configureSubviews() {
    titleLabel.numberOfLines = 0

    textFieldStackView.spacing = 12.0
    textFieldStackView.axis = .vertical
    textFieldStackView.alignment = .top
    textFieldStackView.distribution = .fillProportionally

    emailTextField.returnKeyType = .next
    emailTextField.delegate = self
    emailTextField.tag = 0
    emailTextField.isAccessibilityElement = true
    emailTextField.accessibilityLabel = "email address"
    passwordTextField.returnKeyType = .done
    passwordTextField.tag = 1
    passwordTextField.delegate = self
    passwordTextField.isAccessibilityElement = true
    passwordTextField.accessibilityLabel = "password"
  }

  private func configureLayout() {
    view.layoutMargins = UIEdgeInsets(top: 8.0, left: 16.0, bottom: 0.0, right: 16.0)
    view.addSubViews(titleLabel, actionButton, transitionButton, signInWithSocialButton)

    titleLabel.snp.makeConstraints { make in
      make.top.equalTo(view.snp.topMargin)
      make.leading.equalTo(view.snp.leadingMargin)
      make.trailing.equalTo(view.snp.trailingMargin)
    }

    actionButton.snp.makeConstraints { make in
      make.leading.equalTo(view.snp.leadingMargin)
      make.trailing.equalTo(view.snp.trailingMargin)
      make.height.equalTo(40.0)
      make.bottom.equalTo(transitionButton.snp.top).offset(-16.0)
    }

    transitionButton.snp.makeConstraints { make in
      make.leading.equalTo(view.snp.leadingMargin)
      make.trailing.equalTo(view.snp.trailingMargin)
      make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-35.0)
    }

    signInWithSocialButton.snp.makeConstraints { make in
      make.top.equalTo(actionButton.snp.bottom).offset(20)
      make.leading.equalTo(view.snp.leadingMargin)
      make.trailing.equalTo(view.snp.trailingMargin)
      make.height.equalTo(40.0)
    }

    textFieldStackView.addArrangedSubview(emailTextField)
    textFieldStackView.addArrangedSubview(passwordTextField)

    view.addSubview(textFieldStackView)

    emailTextField.snp.makeConstraints { make in
      make.leading.equalTo(view.snp.leadingMargin)
      make.trailing.equalTo(view.snp.trailingMargin)
      make.height.equalTo(64.0)
    }

    passwordTextField.snp.makeConstraints { make in
      make.leading.equalTo(view.snp.leadingMargin)
      make.trailing.equalTo(view.snp.trailingMargin)
      make.height.equalTo(64.0)
    }

    textFieldStackView.snp.makeConstraints { make in
      make.leading.equalTo(view.snp.leadingMargin)
      make.trailing.equalTo(view.snp.trailingMargin)
      make.top.equalTo(titleLabel.snp.bottom).offset(20.0)
    }
  }

  private func configureReactive() {
    mutableEmail <~ emailTextField.reactive.continuousTextValues
    mutablePassword <~ passwordTextField.reactive.continuousTextValues

    actionButton.reactive.pressed = CocoaAction(loginAction)
    actionButton.reactive.isLoading <~ loginAction.isExecuting
    loginAction.errors.signal.observeValues { [weak self] error in
      self?.presentAlert(error: error)
    }

    transitionButton.reactive.pressed = CocoaAction(transitionAction)

    actionButton.setTitle("Continue", for: .normal)
    transitionButton.isHidden = true

    signInWithSocialButton.setTitle("Continue With Social", for: .normal)
    signInWithSocialButton.reactive.controlEvents(.touchUpInside).observeValues { [weak self] _ in
      guard let self = self else { return }
      let vc = LoginViewControllerSocial(resolver: self.resolver)
      let navVC = UINavigationController(rootViewController: vc)
      vc.navigationItem.leftBarButtonItem = .makeCloseButton(onSelect: { [weak vc] in
        vc?.dismiss(animated: true, completion: nil)
      })
      self.present(navVC, animated: true, completion: nil)
    }

    signInWithSocialButton.isHidden = true
  }
}

extension LoginViewController: UITextFieldDelegate {
  public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if string == "\n" {
      switch textField.tag {
      case 0: passwordTextField.becomeFirstResponder()
      case 1: textField.resignFirstResponder()
      default: break
      }
    }
    return true
  }
}

public class TextField: UITextField {
  public enum Configuration {
    case email
    case password
    case phoneNumber
  }

  private let titleLabel = UILabel()
  private let eyeButton = UIButton()
  private let underline = UIView()

  private let title: String
  private let configuration: Configuration

  public init(_ title: String, configuration: Configuration) {
    self.title = title
    self.configuration = configuration
    super.init(frame: .zero)
    configureSelf()
    configureSubviews()
    configureLayout()
    configureReactive()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  private func configureSelf() {
    autocorrectionType = .no
    autocapitalizationType = .none
    tintColor = .fableRed

    switch configuration {
    case .email:
      isSecureTextEntry = false
      eyeButton.isHidden = true
      keyboardType = .emailAddress
      clearButtonMode = .whileEditing
    case .password:
      isSecureTextEntry = true
      eyeButton.isHidden = false
      keyboardType = .default
      rightView = eyeButton
      rightViewMode = .always
      eyeButton.isHidden = true
    case .phoneNumber:
      isSecureTextEntry = false
      eyeButton.isHidden = true
      keyboardType = .phonePad
    }

    font = .fableFont(18.0, weight: .regular)
  }

  private func configureSubviews() {
    titleLabel.attributedText = title.toAttributedString(.styled(.fableRed, font: .fableFont(14.0, weight: .medium)))
    eyeButton.setImage(#imageLiteral(resourceName: "eyeIconBlack.pdf").withRenderingMode(.alwaysTemplate), for: .normal)
    eyeButton.isSelected = true
    eyeButton.tintColor = .fableDarkGray
    underline.backgroundColor = .fableDarkGray
  }

  private func configureLayout() {
    addSubview(titleLabel)
    addSubview(underline)

    titleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(layoutMargins)
      make.top.equalToSuperview()
    }

    underline.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.bottom.equalToSuperview()
      make.height.equalTo(1.0)
    }
  }

  private func configureReactive() {
    eyeButton.reactive.pressed = .invoke(Action { [weak self] in
      guard let self = self else { return .empty }
      self.isSecureTextEntry = !self.isSecureTextEntry
      let isSelected = !self.eyeButton.isSelected
      self.eyeButton.isSelected = isSelected
      self.eyeButton.tintColor = isSelected ? .fableDarkGray : .fableBlack
      return .empty
    })

    let textIsEmpty = reactive.continuousTextValues.producer.map { $0.isEmpty }

    switch configuration {
    case .email:
      break
    case .password:
      eyeButton.reactive.isHidden <~ textIsEmpty
    case .phoneNumber:
      break
    }
  }

  override public func editingRect(forBounds bounds: CGRect) -> CGRect {
    bounds.offsetBy(dx: 0.0, dy: (frame.height / 2.0) - titleLabel.frame.size.height)
  }

  override public func textRect(forBounds bounds: CGRect) -> CGRect {
    bounds.offsetBy(dx: 0.0, dy: (frame.height / 2.0) - titleLabel.frame.size.height)
  }

  override public func rightViewRect(forBounds bounds: CGRect) -> CGRect {
    var newBounds = bounds
    switch configuration {
    case .email:
      break
    case .password:
      newBounds.size = CGSize(width: 22.0, height: 14.0)
      newBounds.origin.x = frame.width - (newBounds.size.width / 2.0) - 8.0
      newBounds.origin.y = (frame.height / 2.0) + 3.5
    case .phoneNumber:
      break
    }
    return newBounds
  }

  override public func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
    var newBounds = bounds
    newBounds.size = CGSize(width: 16.0, height: 16.0)
    newBounds.origin.x = frame.width - (newBounds.size.width / 2.0) - 8.0
    newBounds.origin.y = (frame.height / 2.0) + 2.0
    return newBounds
  }
}
