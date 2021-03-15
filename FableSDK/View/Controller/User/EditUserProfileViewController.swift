//
//  EditUserProfileViewController.swift
//  Fable
//
//  Created by Andrew Aquino on 12/23/19.
//

import AppFoundation
import AppUIFoundation
import FableSDKResolver
import FableSDKModelManagers
import FableSDKModelObjects
import FableSDKResourceManagers
import FableSDKUIFoundation
import FableSDKViews
import FableSDKWireObjects
import Kingfisher
import ReactiveSwift
import SnapKit
import UIKit

public class EditUserProfileViewController: UIViewController {
  private let resolver: FBSDKResolver
  private let resourceManager: ResourceManager
  private let userManager: UserManager
  private let stateManager: StateManager
  private let authManager: AuthManager

  public init(
    resolver: FBSDKResolver
  ) {
    self.resolver = resolver
    self.resourceManager = resolver.get()
    self.userManager = resolver.get()
    self.stateManager = resolver.get()
    self.authManager = resolver.get()
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder: NSCoder) {
    fatalError()
  }

  private let imagePickerAction = ImagePickerViewControllerBuilder.makeImagePickerAction()

  private let scrollableStackView = ScrollableStackView()

  private let uploadContainer = UIView()
  private let userProfileUploadView = ImageUploadView.new {
    $0.layer.cornerRadius = 45.0
  }

  private let userProfileLabel = UILabel()

  private let userNameInput = IconTextViewButton(
    icon: UIImage(named: "@icon"),
    title: "Username"
  )
  private let biographyInput = IconTextViewButton(
    icon: UIImage(named: "bioIcon"),
    title: "Biography"
  )

  override public func viewDidLoad() {
    super.viewDidLoad()

    // self

    title = "Story Details"
    view.backgroundColor = .fableWhite

    // layout

    uploadContainer.layoutMargins = UIEdgeInsets(top: 24.0, left: 24.0, bottom: 24.0, right: 24.0)

    uploadContainer.addSubview(userProfileUploadView)
    uploadContainer.addSubview(userProfileLabel)
    scrollableStackView.addArrangedSubview(uploadContainer)

    scrollableStackView.addArrangedSubviews([
      userNameInput,
      biographyInput,
    ])

    view.addSubview(scrollableStackView)

    scrollableStackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    uploadContainer.snp.makeConstraints { make in
      make.width.equalToSuperview()
      make.height.equalTo(250.0)
    }

    userProfileUploadView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(28.0)
      make.centerX.equalToSuperview()
      make.width.equalTo(90.0)
      make.height.equalTo(90.0)
    }

    userProfileLabel.snp.makeConstraints { make in
      make.top.equalTo(userProfileUploadView.snp.bottom).offset(16.0)
      make.centerX.equalToSuperview()
    }

    userNameInput.snp.makeConstraints { make in
      make.width.equalToSuperview()
    }

    biographyInput.snp.makeConstraints { make in
      make.width.equalToSuperview()
    }

    // subviews

    userProfileUploadView.reactive.pressed = .invoke { [weak self] in
      self?.presentImagePicker()
    }

    userProfileLabel.text = "Profile photo"
    userProfileLabel.textColor = .fableTextGray
    userProfileLabel.font = .fableFont(14.0, weight: .light)

    configureReactive()

    initialize()
  }

  private func initialize() {
    refresh()
    update()
  }

  private func refresh() {}

  private func update() {
    let currentUser = userManager.currentUser
    if let url = currentUser?.avatarAsset?.objectUrl {
      userProfileUploadView.kf.setImage(with: url, for: .normal)
    } else {
      userProfileUploadView.setImage(nil, for: .normal)
    }

    userNameInput.textView.text = currentUser?.userName
    biographyInput.textView.text = currentUser?.biography
  }

  private func presentImagePicker() {
    imagePickerAction.apply(self).startWithResult { [weak self] actionResult in
      if case let .success(result) = actionResult {
        switch result {
        case .cancelled:
          break
        case let .selected(image):
          self?.setProfileImage(image: image)
        }
      }
    }
  }

  override public func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }

  override public func viewDidAppear(_ animated: Bool) {}

  private func configureReactive() {
    userNameInput.reactive.pressed = .invoke { [weak self] in
      guard let self = self else { return }
      self.presentUserNameInput()
    }

    biographyInput.reactive.pressed = .invoke { [weak self] in
      guard let self = self else { return }
      self.presentBiographyInput()
    }

    stateManager.onUpdate.take(duringLifetimeOf: self).observeValues { [weak self] _ in
      self?.update()
    }
  }

  private func setProfileImage(image: UIImage) {
    guard
      let userId = authManager.authenticatedUserId,
      let data = image.pngData()
      else { return }
    resourceManager.uploadAsset(
      userId: userId,
      asset: data,
      fileName: "avatar.png",
      tags: [
        "user_id_\(userId)",
        "avatar"
      ]
    ).flatMap(.latest) { [weak self] asset -> SignalProducer<Void, Exception> in
      guard let asset = asset, let self = self else { return .empty }
      self.setProfileImage(url: asset.objectUrl)
      return self.resourceManager.updateUser(userId: userId, avatarAssetId: asset.assetId)
    }.start()
  }
  
  private func setProfileImage(url: URL) {
    userProfileUploadView.kf.setImage(with: url, for: .normal)
  }

  private func presentUserNameInput() {
    let vc = TextInputViewController(TextInputViewController.Configuration(
      title: Property<String>(value: "Username"),
      initialText: userManager.currentUser?.userName,
      textAttributes: TextAttributes.body14(),
      attributedPlaceholderText: "User1234".toAttributedString(
        TextAttributes.body14(.fablePlaceholderGray)
      ),
      borderViewModel: FableBorderViewModel.regular
    ))
    vc.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backButton")) { [weak vc, weak self] in
        guard let self = self else { return }
        if let userName = vc?.textView.text {
            self.stateManager.modifyState { state in
                state.currentUser = state.currentUser?.copy(userName: userName)
            }
            self.view.layoutIfNeeded()
            self.updateRemote()
        }
      vc?.navigationController?.popViewController(animated: true)
    }
    vc.onKeyReturn = { [weak self, weak vc] string in
      guard let self = self else { return }
      self.stateManager.modifyState { state in
        state.currentUser = state.currentUser?.copy(userName: string)
      }
      self.view.layoutIfNeeded()
      self.updateRemote()
      vc?.navigationController?.popViewController(animated: true)
    }
    navigationController?.pushViewController(vc, animated: true)
  }

  private func presentBiographyInput() {
    let vc = TextInputViewController(TextInputViewController.Configuration(
      title: Property<String>(value: "Biography"),
      initialText: userManager.currentUser?.biography,
      textAttributes: TextAttributes.body14(),
      attributedPlaceholderText: "I am a great writer.".toAttributedString(
        TextAttributes.body14(.fablePlaceholderGray)
      ),
      borderViewModel: FableBorderViewModel.regular
    ))
    vc.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backButton")) { [weak vc] in
      vc?.navigationController?.popViewController(animated: true)
    }
    vc.onKeyReturn = { [weak self, weak vc] string in
      guard let self = self else { return }
      self.stateManager.modifyState { state in
        state.currentUser = state.currentUser?.copy(biography: string)
      }
      self.view.layoutIfNeeded()
      self.updateRemote()
      vc?.navigationController?.popViewController(animated: true)
    }
    navigationController?.pushViewController(vc, animated: true)
  }

  private func updateRemote() {
    guard let currentUser = userManager.currentUser else { return }
    resourceManager.updateUser(
      userId: currentUser.userId,
      userName: currentUser.userName,
      biography: currentUser.biography
    ).start()
  }
}
