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
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  // MARK: Subviews

  private let titleLabel = UILabel.create {
    $0.numberOfLines = 0
  }

  private let actionButton = Button(FableButtonViewModel.action())
  private let actionButton2 = Button(FableButtonViewModel.plain())

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
  }

  private func configureSubviews() {
    titleLabel.attributedText = "Tell your story.\nCreate something awesome."
      .title16(.fableBlack, alignment: .center)

    actionButton.title = "START A NEW STORY"
    actionButton.addShadow(FableShadowViewModel.regular)
    actionButton.addTarget(self, action: #selector(createStoryButtonTapped(button:)), for: .touchUpInside)
    
    actionButton2.title = "CONTINUE MOST RECENT STORY"
    actionButton2.addShadow(FableShadowViewModel.regular)
    actionButton2.addTarget(self, action: #selector(continueRecentStoryDraft(button:)), for: .touchUpInside)
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
