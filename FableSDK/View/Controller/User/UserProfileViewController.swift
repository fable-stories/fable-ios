//
//  UserProfileViewController.swift
//  Fable
//
//  Created by Andrew Aquino on 8/5/19.
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
import FableSDKViews
import FableSDKWireObjects
import Firebolt
import NetworkFoundation
import ReactiveCocoa
import ReactiveSwift
import SnapKit
import UIKit

/// TODO: Deprecate this
public class UserProfileViewController: UIViewController {
  private var publishedStories: [Story] = []
  private var unpublishedStories: [Story] = []

  private let resolver: FBSDKResolver
  private let authManager: AuthManager
  private let stateManager: StateManagerReadOnly
  private let userManager: UserManager
  private let eventManager: EventManager
  private let resourceManager: ResourceManager
  private let networkManager: NetworkManager
  private let storyDraftManager: StoryDraftManager
  private let dataStoreManager: DataStoreManager

  public init(
    resolver: FBSDKResolver
  ) {
    self.resolver = resolver
    self.authManager = resolver.get()
    self.stateManager = resolver.get(expect: StateManager.self)
    self.eventManager = resolver.get()
    self.resourceManager = resolver.get()
    self.userManager = resolver.get()
    self.networkManager = resolver.get()
    self.storyDraftManager = resolver.get()
    self.dataStoreManager = resolver.get()
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  private let profileContentContainer = UIView()
  private let profileImageView = UIButton()

  private let userNameLabel = UILabel.create {
    $0.font = .fableFont(14.0, weight: .medium)
    $0.textAlignment = .center
    $0.textColor = .fableBlack
  }

  private let biographyTextView = UITextView.create {
    $0.font = .fableFont(14.0, weight: .medium)
    $0.textAlignment = .center
    $0.textColor = .fableBlack
    $0.textContainerInset = .zero
    $0.isSelectable = false
    $0.isEditable = false
  }

  private static let publishedStories = "publishedStories"
  private static let draftedStories = "draftedStories"
  private let selector = HorizontalSelector(
    initialSelectedViewId: UserProfileViewController.draftedStories,
    tintColor: .fableBlack
  )
  private let publishedButton = Button(FableButtonViewModel.selectorPlain())
  private let draftsButton = Button(FableButtonViewModel.selectorPlain())

  private let padding = UIView()

  private let publishedCarouselView = CarouselView(
    itemSize: StoryContainerView.size,
    itemSpacing: 10.0,
    isInfinite: false
  ).also {
    $0.tag = 0
  }

  private let draftsCarouselView = CarouselView(
    itemSize: StoryContainerView.size,
    itemSpacing: 10.0,
    isInfinite: false
  ).also {
    $0.tag = 1
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
    configureSelf()
    configureSubviews()
    configureLayout()
    configureReactive()
    initialize()
  }

  override public func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    refresh()
  }

  override public func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }

  private func configureSelf() {
    navigationItem.title = "FABLE"
    view.backgroundColor = .white
  }

  private func configureSubviews() {
    profileImageView.backgroundColor = .fableGray
    profileImageView.layer.cornerRadius = 45.0
    profileImageView.layer.masksToBounds = true
    profileImageView.reactive.pressed = .invoke { [weak self] in
      self?.presentOptionsForUserProfileIcon()
    }

    publishedButton.title = "Published Stories"
    draftsButton.title = "Drafts"

    padding.addBorder(.top, viewModel: FableBorderViewModel.regular)

    publishedCarouselView.delegate = self
    draftsCarouselView.delegate = self
  }

  private func configureLayout() {
    view.layoutMargins = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 20.0, right: 16.0)

    view.addSubview(profileContentContainer)
    profileContentContainer.addSubview(profileImageView)
    profileContentContainer.addSubview(userNameLabel)
    profileContentContainer.addSubview(biographyTextView)

    view.addSubview(publishedButton)
    view.addSubview(draftsButton)

    view.addSubview(padding)

    view.addSubview(publishedCarouselView)
    view.addSubview(draftsCarouselView)

    profileContentContainer.snp.makeConstraints { make in
      make.top.equalTo(view.snp.top)
      make.leading.equalTo(view.snp.leading)
      make.trailing.equalTo(view.snp.trailing)
      make.bottom.equalTo(publishedButton.snp.top)
    }

    profileImageView.snp.makeConstraints { make in
      make.centerX.equalTo(profileContentContainer.snp.centerX)
      make.centerY.equalTo(profileContentContainer.snp.centerY).offset(-30.0)
      make.width.equalTo(90.0)
      make.height.equalTo(90.0)
    }

    userNameLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(profileImageView.snp.bottom).offset(16.0)
      make.leading.equalToSuperview().inset(view.layoutMargins)
      make.trailing.equalToSuperview().inset(view.layoutMargins)
    }

    biographyTextView.snp.makeConstraints { make in
      make.top.equalTo(userNameLabel.snp.bottom).offset(16.0)
      make.bottom.equalToSuperview()
      make.leading.equalToSuperview().inset(view.layoutMargins)
      make.trailing.equalToSuperview().inset(view.layoutMargins)
    }

    publishedButton.snp.makeConstraints { make in
      make.leading.equalTo(view.snp.leadingMargin)
      make.trailing.equalTo(view.snp.centerX)
      make.bottom.equalTo(padding.snp.top)
      make.height.equalTo(40.0)
    }

    draftsButton.snp.makeConstraints { make in
      make.leading.equalTo(view.snp.centerX)
      make.trailing.equalTo(view.snp.trailingMargin)
      make.bottom.equalTo(padding.snp.top)
      make.height.equalTo(40.0)
    }

    padding.snp.makeConstraints { make in
      make.leading.equalTo(view.snp.leading)
      make.trailing.equalTo(view.snp.trailing)
      make.bottom.equalTo(draftsCarouselView.snp.top)
      make.height.equalTo(20.0)
    }

    publishedCarouselView.snp.makeConstraints { make in
      make.leading.equalTo(view.snp.leading).offset(10.0)
      make.trailing.equalTo(view.snp.trailing).offset(-10.0)
      make.height.equalTo(180.0)
      make.bottom.equalTo(view.snp.bottomMargin)
    }

    draftsCarouselView.snp.makeConstraints { make in
      make.leading.equalTo(view.snp.leading).offset(10.0)
      make.trailing.equalTo(view.snp.trailing).offset(-10.0)
      make.height.equalTo(180.0)
      make.bottom.equalTo(view.snp.bottomMargin)
    }
  }

  private func configureReactive() {
    let isPublishedSelected: Property<Bool> = selector.selectedViewId.map {
      $0 == UserProfileViewController.publishedStories
    }

    publishedButton.reactive.isSelected <~ isPublishedSelected
    publishedCarouselView.reactive.isHidden <~ isPublishedSelected.negate()

    publishedButton.reactive.pressed = .invoke { [weak self] in
      self?.selector.select(viewId: UserProfileViewController.publishedStories)
    }

    let isDraftsSelected: Property<Bool> = selector.selectedViewId.map {
      $0 == UserProfileViewController.draftedStories
    }

    draftsButton.reactive.isSelected <~ isDraftsSelected
    draftsCarouselView.reactive.isHidden <~ isDraftsSelected.negate()

    draftsButton.reactive.pressed = .invoke { [weak self] in
      self?.selector.select(viewId: UserProfileViewController.draftedStories)
    }

    eventManager.onEvent.sinkDisposed(receiveCompletion: nil) { [weak self] event in
      guard let self = self else { return }
      switch event {
      case AuthManagerEvent.userDidSignIn:
        self.update()
        self.dismiss(animated: true) { [weak self] in
          self?.refresh()
        }
      case WorkspaceEvent.deleteStoryEvent:
        self.update()
        self.dismiss(animated: true) { [weak self] in
          self?.refresh()
        }
      default:
        break
      }
    }

    stateManager.onUpdate.take(duringLifetimeOf: self).observeValues { [weak self] _ in
      self?.update()
    }
  }

  private func setProfileImage(image: UIImage) {
    guard
      let userId = userManager.currentUser?.userId,
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
    profileImageView.kf.setImage(with: url, for: .normal)
  }

  private func initialize() {
    update()
  }

  private func refresh() {
    guard let userId = stateManager.state().currentUser?.userId else { return }
    resourceManager.refreshUserMe().start()
    resourceManager.refreshStories(userId: userId).startWithValues { [weak self] wires in
      guard let self = self else { return }
      let stories = wires.compactMap { MutableStory(wire: $0) }
      self.publishedStories = stories.filter { $0.isPublished }
      self.unpublishedStories = stories.filter { !$0.isPublished }
      self.update()
    }
  }

  private func update() {
    guard let currentUser = userManager.currentUser else {
      publishedStories.removeAll()
      unpublishedStories.removeAll()
      publishedCarouselView.reloadData()
      draftsCarouselView.reloadData()
      profileImageView.setImage(UIImage(named: "profile_icon_placeholder"), for: .normal)
      userNameLabel.text = nil
      biographyTextView.text = nil
      return
    }

    if let url = currentUser.avatarAsset?.objectUrl {
      self.profileImageView.kf.setImage(with: url, for: .normal)
    } else {
      self.profileImageView.setImage(UIImage(named: "profile_icon_placeholder"), for: .normal)
    }

    userNameLabel.text = currentUser.userName.isNilOrEmpty
      ? (currentUser.email ?? "")
      : "@\(currentUser.userName!)"

    biographyTextView.text = currentUser.biography

    publishedCarouselView.reloadData()
    draftsCarouselView.reloadData()
  }

  // MARK: - Presenter Methods
  
  private func presentOptionsForUserProfileIcon() {
    guard authManager.isLoggedIn else { return }
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { [weak self] _ in
      guard let self = self else { return }
      ImagePickerViewControllerBuilder.present(from: self, resultCallback: { [weak self] result in
        switch result {
        case let .selected(image):
          self?.setProfileImage(image: image)
        case .cancelled:
          self?.dismiss(animated: true, completion: nil)
        }
      })
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    present(alert, animated: true, completion: nil)
  }

  private func presentStoryEditor(forStory story: Story) {
    self.eventManager.sendEvent(RouterRequestEvent.present(.story(storyId: story.storyId), viewController: self))
  }
}

extension UserProfileViewController: CaraouselViewDelegate {
  public func carouselView(_ carouselView: CarouselView, numberOfItemsIn collectionView: UICollectionView) -> Int {
    if carouselView.tag == 0 {
      return publishedStories.count
    }
    return unpublishedStories.count
  }

  public func carouselView(_ carouselView: CarouselView, collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
    if carouselView.tag == 0 {
      let cell = collectionView.dequeueReusableCell(for: StoryContainerCollectionViewCell.self, at: indexPath)
      let story = publishedStories[indexPath.row]
      cell.story = story
      cell.storyContainerView.selectionContainer.reactive.pressed = .invoke { [weak self] in
        self?.presentStoryEditor(forStory: story)
      }
      return cell
    }

    let cell = collectionView.dequeueReusableCell(for: StoryContainerCollectionViewCell.self, at: indexPath)
    let story = unpublishedStories[indexPath.row]
    cell.story = story
    cell.storyContainerView.selectionContainer.reactive.pressed = .invoke { [weak self] in
      self?.presentStoryEditor(forStory: story)
    }
    return cell
  }
}

public class HorizontalSelector: UIView {
  private lazy var mutableSelectedViewId = MutableProperty<String?>(initialSelectedViewId)
  public private(set) lazy var selectedViewId = ReactiveSwift.Property<String?>(
    capturing: mutableSelectedViewId
  ).skipRepeats()

  private let initialSelectedViewId: String?

  public init(initialSelectedViewId: String?, tintColor: UIColor) {
    self.initialSelectedViewId = initialSelectedViewId
    super.init(frame: .zero)
    self.tintColor = tintColor
    configureSelf()
    configureLayout()
    configureReactive()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  private let stackView = UIStackView.create {
    $0.axis = .horizontal
  }

  private let selector = UIView()

  private func configureSelf() {
    stackView.distribution = .fillEqually
    stackView.alignment = .center

    selector.backgroundColor = tintColor
  }

  private func configureLayout() {
    addSubview(stackView)
    addSubview(selector)

    stackView.snp.makeConstraints { make in
      make.edges.equalTo(snp.edges)
    }
  }

  private func configureReactive() {
    mutableSelectedViewId.producer.take(duringLifetimeOf: self).startWithValues { [weak self] selectedViewId in
      guard let self = self else { return }
      guard let selectedViewId = selectedViewId, let view = self.views[selectedViewId] else { return }
      self.selector.snp.makeConstraints { make in
        make.width.equalTo(view.snp.width)
        make.centerX.equalTo(view.snp.centerX)
      }
      UIView.animate(withDuration: 1.0, animations: {
        self.layoutIfNeeded()
      })
    }
  }

  private var views: [String: UIView] = [:]

  public func addArrangedSubview(_ view: UIView, viewId: String) {
    views[viewId] = view
    stackView.addArrangedSubview(view)
  }

  public func select(viewId: String) {
    mutableSelectedViewId.value = viewId
  }
}
