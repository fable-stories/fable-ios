//
//  CKLandingViewController.swift
//  Fable
//
//  Created by Andrew Aquino on 7/21/19.
//

import AppFoundation
import AppUIFoundation
import FableSDKResolver
import FableSDKModelManagers
import FableSDKModelObjects
import FableSDKResourceManagers
import FableSDKResourceTargets
import FableSDKUIFoundation
import FableSDKViewPresenters
import Firebolt
import ReactiveCocoa
import ReactiveSwift
import SnapKit
import UIKit
import FableSDKFoundation

public enum WriterDashboardEvent: EventContext {
  case didStartNewStory
}

public class CKLandingViewController: UIViewController {
  private let resolver: FBSDKResolver
  private let networkManager: NetworkManager
  private let stateManager: StateManagerReadOnly
  private let eventManager: EventManager
  private let authManager: AuthManager
  private let resourceManager: ResourceManager
  private let storyDraftManager: StoryDraftManager
  private let configManager: ConfigManager

  public init(
    resolver: FBSDKResolver
  ) {
    self.resolver = resolver
    self.networkManager = resolver.get()
    self.stateManager = resolver.get(expect: StateManager.self)
    self.eventManager = resolver.get()
    self.authManager = resolver.get()
    self.resourceManager = resolver.get()
    self.storyDraftManager = resolver.get()
    self.configManager = resolver.get()
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  // MARK: Subviews

  private let titleLabel = UILabel.new {
    $0.numberOfLines = 0
  }

  private let actionButton = Button(FableButtonViewModel.action())
  private let actionButton2 = Button(FableButtonViewModel.plain())
  
  private let container = UIView()
  private let containerStackView: UIStackView = {
    let view = UIStackView()
    view.alignment = .center
    view.axis = .vertical
    view.distribution = .fillProportionally
    view.spacing = 8.0
    return view
  }()
  private let telegramButton = Button(FableButtonViewModel.plain())
  private let shareButton = Button(FableButtonViewModel.plain())

  // MARK: View Life Cycle

  override public func viewDidLoad() {
    super.viewDidLoad()
    configureSelf()
    configureLayout()
    configureSubviews()
    configureGestures()
    configureReactive()
  }

  override public func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }

  private func configureSelf() {
    navigationItem.title = "FABLE"
    view.backgroundColor = .fableWhite

    navigationController?.setNavigationBarHidden(false, animated: false)
  }

  private func configureLayout() {
    view.layoutMargins = UIEdgeInsets(top: 36.0, left: 32.0, bottom: 32.0, right: 32.0)

    view.addSubview(titleLabel)
    view.addSubview(actionButton)
    view.addSubview(actionButton2)
    
    view.addSubview(container)
    container.addSubview(containerStackView)
    containerStackView.addArrangedSubview(telegramButton)
    containerStackView.addArrangedSubview(shareButton)

    titleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(view.layoutMargins)
      make.trailing.equalToSuperview().inset(view.layoutMargins)
      make.top.equalToSuperview().inset(view.layoutMargins)
    }

    actionButton.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(24.0)
      make.leading.equalToSuperview().inset(view.layoutMargins)
      make.trailing.equalToSuperview().inset(view.layoutMargins)
      make.height.equalTo(40.0)
    }
    
    actionButton2.snp.makeConstraints { make in
      make.top.equalTo(actionButton.snp.bottom).offset(12.0)
      make.leading.equalToSuperview().inset(view.layoutMargins)
      make.trailing.equalToSuperview().inset(view.layoutMargins)
      make.height.equalTo(40.0)
    }
    
    container.snp.makeConstraints { make in
      make.top.equalTo(actionButton2.snp.bottom)
      make.leading.equalToSuperview().inset(view.layoutMargins)
      make.trailing.equalToSuperview().inset(view.layoutMargins)
      make.bottom.equalToSuperview().inset(view.layoutMargins)
    }
    
    containerStackView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
    }
    
    telegramButton.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.height.equalTo(40.0)
    }
    
    shareButton.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.height.equalTo(40.0)
    }
  }

  private func configureSubviews() {
    titleLabel.attributedText = "Tell your story.\nCreate something awesome."
      .title16(.fableBlack, alignment: .center)

    actionButton.title = "START A NEW STORY"
    actionButton.addShadow(FableShadowViewModel.regular)
    actionButton.addTarget(self, action: #selector(createStoryButtonTapped(button:)), for: .touchUpInside)
    
    actionButton2.title = "CONTINUE MOST RECENT STORY"
    actionButton2.addTarget(self, action: #selector(continueRecentStoryDraft(button:)), for: .touchUpInside)
    
    let telegramIcon = UIImage(named: "telegram_icon")?.resized(to: .sizeWithConstantDimensions(24.0))
    telegramButton.setImage(telegramIcon, for: .normal)
    telegramButton.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 8.0)
    telegramButton.addTarget(self, action: #selector(didTapOnTelegramCTA), for: .touchUpInside)
    telegramButton.title = "Join our Telegram group!"
    
    shareButton.title = "Share this App"
    shareButton.addTarget(self, action: #selector(didTapOnShareCTA), for: .touchUpInside)
  }

  private func configureGestures() {}

  private func configureReactive() {
    eventManager.onEvent.sinkDisposed(receiveCompletion: nil) { [weak self] eventContext in
      guard let self = self else { return }
      if case AuthManagerEvent.userDidSignIn = eventContext {
        self.dismiss(animated: true, completion: nil)
      }
    }
  }
  
  @objc private func createStoryButtonTapped(button: UIButton) {
    if authManager.isLoggedIn {
      self.eventManager.sendEvent(RouterRequestEvent.present(.storyEditor(.newStory), viewController: self))
    } else {
      self.presentLogin()
    }
  }
  
  @objc private func continueRecentStoryDraft(button: UIButton) {
    if authManager.isLoggedIn {
      self.eventManager.sendEvent(RouterRequestEvent.present(.storyEditor(.recentStory), viewController: self))
    } else {
      self.presentLogin()
    }
  }
  
  @objc private func didTapOnTelegramCTA() {
    guard let url = URL(string: "https://t.me/fablestories") else { return }
    UIApplication.shared.open(url)
  }
  
  @objc private func didTapOnShareCTA() {
    let shareLink = "https://testflight.apple.com/join/zwgj88F3"
    UIPasteboard.general.string = shareLink
    let alert = UIAlertController(title: "Copied!", message: shareLink, preferredStyle: .alert)
    alert.addAction(.init(title: "Okay", style: .default, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }

  private func presentLogin() {
    let vc = LoginViewControllerSocial(resolver: self.resolver)
    vc.navigationItem.leftBarButtonItem = .makeCloseButton(onSelect: { [weak self] in
      self?.dismiss(animated: true, completion: nil)
    })
    let navVC = UINavigationController(rootViewController: vc)
    self.present(navVC, animated: true, completion: nil)
  }
}

extension CKLandingViewController: UITextFieldDelegate {
  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
