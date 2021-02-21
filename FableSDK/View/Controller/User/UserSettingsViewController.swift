//
//  UserSettingsViewController.swift
//  Fable
//
//  Created by Ashley Carey on 10/13/19.
//

import AppFoundation
import AppUIFoundation
import FableSDKResolver
import FableSDKModelObjects
import FableSDKModelManagers
import FableSDKViews
import FableSDKUIFoundation
import Firebolt
import ReactiveSwift
import UIKit

public protocol UserSettingsViewControllerDelegate: AnyObject {
  func popViewController(viewController: UIViewController)
  func presentLogin(viewController: UIViewController)
}

public class UserSettingsViewController: UITableViewController {
  public enum MenuOption: String {
    case editProfile = "Edit Profile"
    case login = "Login"
    case logout = "Logout"
    case onboarding = "Onboarding"
    case adminPanel = "Admin Panel"
    case privacyPolicy = "Privacy Policy"
    case termsOfService = "Terms of Service"
  }

  private let resolver: FBSDKResolver
  private let authManager: AuthManager
  private let stateManager: StateManager
  private let envManager: EnvironmentManager
  private let userManager: UserManager

  public weak var delegate: UserSettingsViewControllerDelegate?

  public init(
    resolver: FBSDKResolver
  ) {
    self.resolver = resolver
    self.authManager = resolver.get()
    self.envManager = resolver.get()
    self.stateManager = resolver.get()
    self.userManager = resolver.get()
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder: NSCoder) {
    fatalError()
  }

  private var menuOptions: [MenuOption] = []

  override public func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.title = "Settings"
    tableView.separatorColor = .clear
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)

    stateManager.onUpdate.take(duringLifetimeOf: self).observeValues { [weak self] _ in
      self?.update()
    }

    update()
  }

  override public func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }

  private func presentEditProfile() {
    let vc = EditUserProfileViewController(resolver: resolver)
    vc.navigationItem.leftBarButtonItem = .makeBackButton(onSelect: { [weak self] in
      self?.navigationController?.popViewController(animated: true)
    })
    navigationController?.pushViewController(vc, animated: true)
  }

  private func presentOnboarding() {
    let vc = OnboardViewController(resolver: resolver)
    navigationController?.present(vc.wrapInNavigationController { [weak self] in
      self?.dismiss(animated: true, completion: nil)
    }, animated: true, completion: nil)
  }
  
  private func presentPrivacyPolicy() {
    let initialString: String = {
      if let filepath = Bundle.main.path(forResource: "privacy_policy", ofType: "md") {
        do {
          return try String(contentsOfFile: filepath)
        } catch let error {
          print(error)
        }
      }
      return ""
    }()
    let vc = MarkdownViewController(
      viewModel: .init(
        initialString: initialString,
        navigationTitle: "Fable Privacy Policy"
      )
    )
    let navVC = UINavigationController(rootViewController: vc)
    vc.navigationItem.leftBarButtonItem = .makeCloseButton(onSelect: { [weak vc] in
      vc?.dismiss(animated: true, completion: nil)
    })
    self.present(navVC, animated: true, completion: nil)

  }
  
  public func presentEulaAgreement() {
    let initialString: String = {
      if let filepath = Bundle.main.path(forResource: "terms_of_service", ofType: "md") {
        do {
          return try String(contentsOfFile: filepath)
        } catch let error {
          print(error)
        }
      }
      return ""
    }()
    // TODO: log this
    if initialString.isEmpty { return }
    let actionButton = Button(FableButtonViewModel.primaryButton())
    actionButton.setTitle("Agree", for: .normal)
    actionButton.addTarget(self, action: #selector(didTapEulaButton), for: .touchUpInside)
    let showActionButton: Bool = {
      if let myUser = self.userManager.currentUser {
        return myUser.eulaAgreedAt == nil
      }
      return false
    }()
    let vc = MarkdownViewController(
      viewModel: .init(
        initialString: initialString,
        navigationTitle: "Terms of Service",
        actionButton: showActionButton ? actionButton : nil
      )
    )
    let navVC = UINavigationController(rootViewController: vc)
    vc.navigationItem.leftBarButtonItem = .makeCloseButton(onSelect: { [weak vc] in
      vc?.dismiss(animated: true, completion: nil)
    })
    self.present(navVC, animated: true, completion: nil)
  }
  
  @objc private func didTapEulaButton() {
    self.userManager.agreeToEULA().sinkDisposed(receiveCompletion: nil) { [weak self] _ in
      self?.dismiss(animated: true, completion: nil)
    }
  }

  private func update() {
    let state = stateManager.state()

    let canShowAdminMenu: Bool = {
      if let email = state.currentUser?.email, let admins = state.config?.admins, admins.contains(email) {
        return true
      }
      return false
    }()

    navigationItem.rightBarButtonItem = canShowAdminMenu ? UIBarButtonItem(
      title: envManager.environment.description,
      style: .done,
      target: self, action: #selector(showAdminMenu)
    ).also {
      $0.setTitleTextAttributes(UINavigationBar.titleAttributes(), for: .normal)
      $0.setTitleTextAttributes(UINavigationBar.titleAttributes(), for: .highlighted)
    } : nil

    if authManager.isLoggedIn {
      menuOptions = [.editProfile, .logout, .onboarding, .privacyPolicy, .termsOfService]
    } else {
      menuOptions = [.login, .onboarding, .privacyPolicy, .termsOfService]
    }
    
    if canShowAdminMenu {
      menuOptions.append(.adminPanel)
    }
    
    tableView.reloadData()
  }

  @objc private func showAdminMenu() {
    let message = "\(ApplicationMetadata.source().rawValue.capitalized) \(ApplicationMetadata.versionBuild())"
    let alert = UIAlertController(title: "Admin Menu", message: message, preferredStyle: .actionSheet)
    let currentEnvironment = envManager.environment.description
    alert.addAction(UIAlertAction(title: "Prod\("prod" == currentEnvironment ? " (ACTIVE)" : "")", style: .default, handler: { [weak self] _ in
      self?.envManager.setEnvironment(.prod)
    }))
    alert.addAction(UIAlertAction(title: "Stage\("stage" == currentEnvironment ? " (ACTIVE)" : "")", style: .default, handler: { [weak self] _ in
      self?.envManager.setEnvironment(.stage)
    }))
    alert.addAction(UIAlertAction(title: "Local\("local" == currentEnvironment ? " (ACTIVE)" : "")", style: .default, handler: { [weak self] _ in
      self?.envManager.setEnvironment(.local)
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
    present(alert, animated: true, completion: nil)
  }
}

extension UserSettingsViewController {
  override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    menuOptions.count
  }

  override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    40.0
  }

  override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let menuOption = menuOptions[indexPath.row]

    let cell: UITableViewCell = tableView.dequeueReusableCell(at: indexPath)
    let image: UIImage? = {
      switch menuOption {
      case .editProfile: return UIImage(named: "editProfile")
      case .logout: return UIImage(named: "logout")
      case .login: return UIImage(named: "loginIcon")
      case .privacyPolicy: return nil
      case .onboarding: return nil
      case .adminPanel: return nil
      case .termsOfService: return nil
      }
    }()
    cell.imageView?.image = image?.resized(to: CGSize(width: 16.0, height: 16.0))
    cell.imageView?.contentMode = .scaleAspectFit
    cell.textLabel?.text = menuOption.rawValue
    cell.textLabel?.font = .fableFont(16)

    return cell
  }

  override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    let menuOption = menuOptions[indexPath.row]
    switch menuOption {
    case .editProfile:
      presentEditProfile()
    case .logout:
      authManager.signOut()
      delegate?.popViewController(viewController: self)
    case .login:
      delegate?.presentLogin(viewController: self)
    case .onboarding:
      presentOnboarding()
    case .privacyPolicy:
      presentPrivacyPolicy()
    case .termsOfService:
      self.presentEulaAgreement()
    case .adminPanel:
      showAdminMenu()
    }
  }
}
