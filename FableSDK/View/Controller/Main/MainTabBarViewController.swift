//
//  MainTabBarViewController.swift
//  Fable
//
//  Created by Andrew Aquino on 7/21/19.
//

import AppFoundation
import AppUIFoundation
import FableSDKResolver
import FableSDKModelObjects
import FableSDKUIFoundation
import FableSDKViewPresenters
import FableSDKEnums
import FableSDKModelManagers
import FableSDKFoundation
import FableSDKModelPresenters
import Firebolt
import FirebaseAnalytics
import ReactiveSwift
import UIKit

public enum FBLUserDefaults: String {
  case didShowOnboarding
}

public enum RouterRequestEvent: EventContext {
  case present(Screen, viewController: UIViewController)
  case push(Screen, navigationController: UINavigationController)
  
  public enum Screen {
    case story(storyId: Int)
    case userProfile(userId: Int)
    case storyEditor(storyId: Int?)
    case storyEditorDetails(modelPresenter: StoryDraftModelPresenter)
    case storyDetail(storyId: Int)
    case storyReader(datastore: DataStore)
    case userList(userIds: [Int], title: String)
    case userSettings
    case login
    case onboarding
  }
}

public enum MainTabBarEvent: EventContext {
  case didSelectUserProfileTab
}

public class MainTabBarViewController: UITabBarController {
  private var isPresenting: Bool = false
 
  private let resolver: FBSDKResolver
  private let eventManager: EventManager
  private let analyticsManager: AnalyticsManager
  private let dataStoreManager: DataStoreManager
  private let resourceManager: ResourceManager
  private let userManager: UserManager
  private let authManager: AuthManager

  public init(resolver: FBSDKResolver) {
    self.resolver = resolver
    self.eventManager = resolver.get()
    self.analyticsManager = resolver.get()
    self.dataStoreManager = resolver.get()
    self.resourceManager = resolver.get()
    self.userManager = resolver.get()
    self.authManager = resolver.get()
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder: NSCoder) {
    fatalError()
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
    configureSelf()
    configureTabBar()
    configureViewControllers()
    configureReactive()

    selectedIndex = envInt("starting_index") ?? 0
  }

  override public func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }

  override public func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    /// present onboarding once on app launch
    if UserDefaults.standard.bool(forKey: FBLUserDefaults.didShowOnboarding.rawValue) != true {
      UserDefaults.standard.setValue(true, forKey: FBLUserDefaults.didShowOnboarding.rawValue)
      self.eventManager.sendEvent(RouterRequestEvent.present(.onboarding, viewController: self))
    }
  }

  private func configureSelf() {
    view.backgroundColor = .white
  }

  private func configureTabBar() {
    tabBar.barTintColor = .white
    tabBar.isTranslucent = false
  }

  private func configureViewControllers() {
    let inset: CGFloat = 5.0
    let feedVC: FeedViewControllerV2 = FeedViewControllerV2(resolver: resolver)
    feedVC.tabBarItem = UITabBarItem(
      title: nil,
      image: UIImage(named: "homeTabIcon")?.withRenderingMode(.alwaysOriginal),
      selectedImage: UIImage(named: "homeTabIconSelected")?.withRenderingMode(.alwaysOriginal)
    ).also {
      $0.setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .normal)
    }
    feedVC.tabBarItem.imageInsets = UIEdgeInsets(top: inset, left: 0.0, bottom: -inset, right: 0.0)
    feedVC.tabBarItem.isAccessibilityElement = true
    feedVC.tabBarItem.accessibilityLabel = "Home"
    feedVC.tabBarItem.tag = 0

    let creatorVC: CKLandingViewController = CKLandingViewController(resolver: resolver)
    creatorVC.tabBarItem = UITabBarItem(
      title: nil,
      image: UIImage(named: "creatorTabIcon")?.withRenderingMode(.alwaysOriginal),
      selectedImage: UIImage(named: "creatorTabIconSelected")?.withRenderingMode(.alwaysOriginal)
    ).also {
      $0.setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .normal)
    }
    creatorVC.tabBarItem.imageInsets = UIEdgeInsets(top: inset, left: 0.0, bottom: -inset, right: 0.0)
    creatorVC.tabBarItem.isAccessibilityElement = true
    creatorVC.tabBarItem.accessibilityLabel = "Create a story"
    creatorVC.tabBarItem.tag = 1

    let userProfileVC: UserProfileViewControllerV2 = UserProfileViewControllerV2(resolver: resolver)
    userProfileVC.navigationItem.title = "FABLE"
    userProfileVC.navigationController?.setNavigationBarHidden(false, animated: false)
    userProfileVC.tabBarItem = UITabBarItem(
      title: nil,
      image: UIImage(named: "userProfileTabIcon")?.withRenderingMode(.alwaysOriginal),
      selectedImage: UIImage(named: "userProfileTabIconSelected")?.withRenderingMode(.alwaysOriginal)
    ).also {
      $0.setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .normal)
    }
    userProfileVC.tabBarItem.imageInsets = UIEdgeInsets(top: inset, left: 0.0, bottom: -inset, right: 0.0)
    userProfileVC.tabBarItem.isAccessibilityElement = true
    userProfileVC.tabBarItem.accessibilityLabel = "Profile"
    userProfileVC.tabBarItem.tag = 2

    viewControllers = [
      UINavigationController(rootViewController: feedVC),
      UINavigationController(rootViewController: creatorVC),
      UINavigationController(rootViewController: userProfileVC),
    ]
  }

  private func configureReactive() {
    self.eventManager.onEvent.sinkDisposed(receiveCompletion: nil) { [weak self] event in
      guard let self = self, !self.isPresenting else { return }
      
      self.isPresenting = true
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        self.isPresenting = false
      }

      switch event {
      case let RouterRequestEvent.present(screen, viewController):
        switch screen {
        case .storyDetail(let storyId):
          self.presentStoryDetail(storyId: storyId, presenter: viewController)
        case .storyEditor(let storyId):
          guard let user = self.userManager.currentUser else {
            return self.presentLogin(viewController: viewController)
          }
          if user.eulaAgreedAt == nil {
            self.presentEulaAgreement(presenter: viewController)
          } else if let storyId = storyId {
            self.presentStoryEditor(storyId: storyId, presenter: viewController)
          } else {
            self.presentNewStoryEditor(presenter: viewController)
          }
        case .storyEditorDetails, .userSettings:
          break
        case .story(let storyId):
          self.presentStory(storyId: storyId, presenter: viewController)
        case .storyReader(let datastore):
          self.presentStory(model: datastore, presenter: viewController)
        case .userProfile(let userId):
          print(userId)
        case let .userList(userIds, title):
          let users = self.userManager.fetchUsers(userIds: userIds)
          let vc = self.makeUserListVC(users: users, title: title)
          vc.navigationItem.leftBarButtonItem = .makeCloseButton(onSelect: { [weak viewController] in
            viewController?.dismiss(animated: true, completion: nil)
          })
          let navVC = UINavigationController(rootViewController: vc)
          viewController.present(navVC, animated: true, completion: nil)
        case .login:
          let vc = LoginViewControllerSocial(resolver: self.resolver)
          vc.delegate = self
          let navVC = UINavigationController(rootViewController: vc)
          vc.navigationItem.leftBarButtonItem = .makeCloseButton(onSelect: { [weak vc] in
            vc?.dismiss(animated: true, completion: nil)
          })
          viewController.present(navVC, animated: true, completion: nil)
        case .onboarding:
          let vc = OnboardViewController(resolver: self.resolver)
          viewController.present(vc.wrapInNavigationController { [weak self] in
            self?.dismiss(animated: true, completion: nil)
          }, animated: true, completion: nil)
        }
      case let RouterRequestEvent.push(screen, navigationController):
        switch screen {
        case .storyDetail(let storyId):
          print(storyId)
        case .story(let storyId):
          print(storyId)
        case .storyEditor, .storyReader:
          break
        case .storyEditorDetails(let modelPresenter):
          let vc = EditableStoryDetailViewController(
            resolver: self.resolver,
            modelPresenter: modelPresenter
          )
          vc.navigationItem.leftBarButtonItem = .makeBackButton(onSelect: { [weak navigationController] in
            navigationController?.popViewController(animated: true)
          })
          navigationController.pushViewController(vc, animated: true)
        case .userProfile(let userId):
          let vc = UserProfileViewControllerV2(resolver: self.resolver, userId: userId)
          vc.navigationItem.leftBarButtonItem = .makeBackButton(onSelect: { [weak vc] in
            vc?.navigationController?.popViewController(animated: true)
          })
          navigationController.pushViewController(vc, animated: true)
        case let .userList(userIds, title):
          let users = self.userManager.fetchUsers(userIds: userIds)
          let vc = self.makeUserListVC(users: users, title: title)
          vc.navigationItem.leftBarButtonItem = .makeBackButton(onSelect: { [weak navigationController] in
            navigationController?.popViewController(animated: true)
          })
          navigationController.pushViewController(vc, animated: true)
        case .userSettings:
          let settingsVC = UserSettingsViewController(resolver: self.resolver)
          settingsVC.delegate = self
          settingsVC.navigationItem.leftBarButtonItem = .makeBackButton(onSelect: { [weak settingsVC] in
            settingsVC?.navigationController?.popViewController(animated: true)
          })
          navigationController.pushViewController(settingsVC, animated: true)
        case .login, .onboarding:
          break
        }
      default:
        break
      }
    }
  }
  
  public override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    switch item.tag {
    case 0:
      self.analyticsManager.trackEvent(AnalyticsEvent.didSelectFeedTab)
    case 1:
      self.analyticsManager.trackEvent(AnalyticsEvent.didSelectWriterTab)
    case 2:
      self.analyticsManager.trackEvent(AnalyticsEvent.didSelectUserProfileTab)
      self.eventManager.sendEvent(MainTabBarEvent.didSelectUserProfileTab)
    default: break
    }
  }
  
  private func presentStoryDetail(storyId: Int, presenter: UIViewController) {
    let vc = StoryDetailViewController(resolver: resolver, storyId: storyId)
    vc.navigationItem.leftBarButtonItem = .makeCloseButton(onSelect: { [weak presenter] in
      presenter?.dismiss(animated: true, completion: nil)
    })
    let navVC = UINavigationController(rootViewController: vc)
    presenter.present(navVC, animated: true, completion: nil)
  }
  
  private func presentStory(storyId: Int, presenter: UIViewController) {
    if let datastore = dataStoreManager.fetchDataStore(storyId: storyId) {
      return self.presentStory(model: datastore, presenter: presenter)
    }
    dataStoreManager.refreshDataStore(storyId: storyId).sinkDisposed(receiveCompletion: nil) { [weak self] datastore in
      guard let self = self, let datastore = datastore else { return }
      self.presentStory(model: datastore, presenter: presenter)
    }
  }
  
  private func presentStory(model: DataStore, presenter: UIViewController) {
    guard let vc = RKChapterViewController(resolver: resolver, model: model) else { return }
    let navVC = UINavigationController(rootViewController: vc)
    navVC.modalPresentationStyle = .fullScreen
    vc.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "closeButton")) { [weak self, weak vc, weak presenter] in
      if let vc = vc {
        self?.analyticsManager.trackEvent(AnalyticsEvent.didDismissReader, properties: [
          "story_id": model.story.storyId,
          "chapter_id": model.selectedChapterId,
          "message_id": vc.currentMessageId
        ])
      }
      presenter?.dismiss(animated: true, completion: nil)
    }
    presenter.present(navVC, animated: true, completion: nil)
  }
  
  private func presentNewStoryEditor(presenter viewController: UIViewController) {
    let vc = StoryEditorViewController(resolver: self.resolver)
    let navVC = UINavigationController(rootViewController: vc)
    navVC.modalTransitionStyle = .coverVertical
    navVC.modalPresentationStyle = .fullScreen
    vc.navigationItem.leftBarButtonItem = .makeCloseButton(onSelect: { [weak vc] in
      vc?.dismiss(animated: true, completion: nil)
    })
    viewController.present(navVC, animated: true) { [weak self] in
      self?.eventManager.sendEvent(WriterDashboardEvent.didStartNewStory)
    }
  }
  
  private func presentStoryEditor(storyId: Int, presenter: UIViewController) {
    let vc = StoryEditorViewController(resolver: resolver, storyId: storyId)
    let navVC = UINavigationController(rootViewController: vc)
    navVC.modalTransitionStyle = .coverVertical
    navVC.modalPresentationStyle = .fullScreen
    vc.navigationItem.leftBarButtonItem = .makeCloseButton(onSelect: { [weak presenter] in
      presenter?.dismiss(animated: true, completion: nil)
    })
    presenter.present(navVC, animated: true, completion: nil)
  }

  private func presentStoryPreview(datastore: DataStore, presenter: UIViewController) {
    guard let vc = RKChapterViewController(
      resolver: resolver,
      model: datastore
    ) else { return }
    let navVC = UINavigationController(rootViewController: vc)
    navVC.modalPresentationStyle = .fullScreen
    vc.navigationItem.leftBarButtonItem = .makeCloseButton(onSelect: { [weak presenter] in
      presenter?.dismiss(animated: true, completion: nil)
    })
    presenter.present(navVC, animated: true, completion: nil)
  }

  private func makeUserListVC(users: [User], title: String) -> UIViewController {
    let vc = UserListViewController(resolver: resolver, users: users)
    vc.title = title
    return vc
  }
  
  public func presentEulaAgreement(presenter: UIViewController) {
    let vc = MarkdownViewController(
      initialString: """
      # Hello World!
      ## Hi World!
      """,
      navigationTitle: "End-User Agreement License"
    )
    let navVC = UINavigationController(rootViewController: vc)
    vc.navigationItem.leftBarButtonItem = .makeCloseButton(onSelect: { [weak vc] in
      vc?.dismiss(animated: true, completion: nil)
    })
    presenter.present(navVC, animated: true, completion: nil)
  }
}

extension MainTabBarViewController: UserSettingsViewControllerDelegate {
  public func presentLogin(viewController: UIViewController) {
    let vc = LoginViewControllerSocial(resolver: resolver)
    vc.delegate = self
    vc.navigationItem.leftBarButtonItem = .makeCloseButton(onSelect: { [weak vc] in
      vc?.presentingViewController?.dismiss(animated: true, completion: nil)
    })
    let navVC = UINavigationController(rootViewController: vc)
    let presenterVC = viewController.navigationController
    presenterVC?.popViewController(animated: true, onComplete: { [weak presenterVC] in
      presenterVC?.present(navVC, animated: true, completion: nil)
    })
  }
  
  public func popViewController(viewController: UIViewController) {
    viewController.navigationController?.popViewController(animated: true)
  }
}

extension MainTabBarViewController: LoginViewControllerSocialDelegate {
  public func loginViewController(dismissViewController viewController: LoginViewControllerSocial) {
    viewController.presentingViewController?.dismiss(animated: true, completion: nil)
  }
}
