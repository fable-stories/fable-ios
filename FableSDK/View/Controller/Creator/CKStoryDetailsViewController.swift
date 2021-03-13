//
//  StoryDetailsViewController.swift
//  Fable
//
//  Created by Andrew Aquino on 12/16/19.
//

import AppFoundation
import AppUIFoundation
import FableSDKResolver
import FableSDKModelObjects
import FableSDKResourceManagers
import FableSDKEnums
import FableSDKModelManagers
import FableSDKUIFoundation
import FableSDKViewPresenters
import FableSDKModelPresenters
import Kingfisher
import ReactiveSwift
import SnapKit
import UIKit

public class EditableStoryDetailViewController: UIViewController {
  private enum ImageKind {
    case portrait
    case landscape
  }

  private enum InputKind {
    case title
    case synopsis
  }
  
  private var categories: [Kategory] = []

  private let resolver: FBSDKResolver
  private let resourceManager: ResourceManager
  private let categoryManager: CategoryManager
  private let eventManager: EventManager
  private let assetManager: AssetManager
  
  private let modelPresenter: StoryDraftModelPresenter

  public init(
    resolver: FBSDKResolver,
    workspaceManager: WorkspaceManager
  ) {
    self.resolver = resolver
    self.resourceManager = resolver.get()
    self.categoryManager = resolver.get()
    self.eventManager = resolver.get()
    self.assetManager = resolver.get()
    self.modelPresenter = StoryDraftModelPresenterBuilder.make(resolver: resolver)
    super.init(nibName: nil, bundle: nil)
  }
  
  public init(
    resolver: FBSDKResolver,
    modelPresenter: StoryDraftModelPresenter
  ) {
    self.resolver = resolver
    self.categoryManager = resolver.get()
    self.resourceManager = resolver.get()
    self.eventManager = resolver.get()
    self.assetManager = resolver.get()
    self.modelPresenter = modelPresenter
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder: NSCoder) {
    fatalError()
  }

  private let imagePickerAction = ImagePickerViewControllerBuilder.makeImagePickerAction()

  private let scrollableStackView = ScrollableStackView()

  private let uploadContainer = UIView()
  private let portraitUpload = ImageUploadView()
  private let landscapeUpload = ImageUploadView()

  private let labelContainer = UIView()
  private let portraitUploadLabel = UILabel()
  private let landscapeUploadLabel = UILabel()

  private let titleInput = IconTextViewButton(
    icon: UIImage(named: "bookCoverIcon"),
    title: "Story Title"
  )
  private let categoryInput = IconTextViewButton(
    icon: UIImage(named: "openBookIcon"),
    title: "Category"
  )
  private let synopsisInput = IconTextViewButton(
    icon: UIImage(named: "linesIcon"),
    title: "Synopsis"
  )

  override public func viewDidLoad() {
    super.viewDidLoad()

    // self

    title = "Story Details"
    view.backgroundColor = .fableWhite

    // layout

    uploadContainer.layoutMargins = UIEdgeInsets(top: 24.0, left: 24.0, bottom: 24.0, right: 24.0)

    uploadContainer.addSubview(portraitUpload)
    uploadContainer.addSubview(landscapeUpload)
    scrollableStackView.addArrangedSubview(uploadContainer)
    
    labelContainer.addSubview(portraitUploadLabel)
    labelContainer.addSubview(landscapeUploadLabel)
    scrollableStackView.addArrangedSubview(labelContainer)

    scrollableStackView.addArrangedSubviews([
      titleInput,
      categoryInput,
      synopsisInput,
    ])

    view.addSubview(scrollableStackView)

    scrollableStackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    uploadContainer.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(uploadContainer.layoutMargins)
      make.top.equalToSuperview().inset(uploadContainer.layoutMargins)
      make.width.equalToSuperview().inset(uploadContainer.layoutMargins)
      make.height.equalTo(uploadContainer.snp.width)
    }
    
    portraitUpload.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.trailing.equalTo(uploadContainer.snp.centerX).offset(-6.0)
      make.bottom.equalToSuperview()
      make.height.equalTo(portraitUpload.snp.width).multipliedBy(2.0)
    }

    landscapeUpload.snp.makeConstraints { make in
      make.leading.equalTo(uploadContainer.snp.centerX).offset(6.0)
      make.trailing.equalToSuperview()
      make.bottom.equalToSuperview()
      make.height.equalTo(landscapeUpload.snp.width).dividedBy(2.0)
    }
    
    labelContainer.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.height.equalTo(40.0)
    }

    portraitUploadLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(uploadContainer.layoutMargins)
      make.trailing.equalTo(labelContainer.snp.centerX).inset(uploadContainer.layoutMargins)
      make.top.equalToSuperview().offset(12.0)
      make.height.equalTo(20.0)
    }

    landscapeUploadLabel.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(uploadContainer.layoutMargins)
      make.leading.equalTo(labelContainer.snp.centerX).inset(uploadContainer.layoutMargins)
      make.top.equalToSuperview().offset(12.0)
      make.height.equalTo(20.0)
    }

    titleInput.snp.makeConstraints { make in
      make.width.equalToSuperview()
    }

    categoryInput.snp.makeConstraints { make in
      make.width.equalToSuperview()
    }

    synopsisInput.snp.makeConstraints { make in
      make.width.equalToSuperview()
    }

    // subviews

    portraitUpload.reactive.pressed = .invoke { [weak self] in
      self?.presentImagePicker(imageKind: .portrait)
    }

    landscapeUpload.reactive.pressed = .invoke { [weak self] in
      self?.presentImagePicker(imageKind: .landscape)
    }

    portraitUploadLabel.text = "Portrait Image"
    portraitUploadLabel.accessibilityLabel = "Set Portrait Image"
    portraitUploadLabel.textColor = .fableTextGray
    portraitUploadLabel.font = .fableFont(14.0, weight: .light)
    portraitUploadLabel.textAlignment = .center
    landscapeUploadLabel.text = "Landscape Image"
    landscapeUpload.accessibilityLabel = "Set Landscape Image"
    landscapeUploadLabel.textColor = .fableTextGray
    landscapeUploadLabel.font = .fableFont(14.0, weight: .light)
    landscapeUploadLabel.textAlignment = .center
    

    titleInput.reactive.pressed = .invoke { [weak self] in
      guard let self = self else { return }
      self.presentStoryTitleInput()
    }

    categoryInput.reactive.pressed = .invoke { [weak self] in
      guard let self = self else { return }
      self.presentCategorySelection()
    }

    synopsisInput.reactive.pressed = .invoke { [weak self] in
      guard let self = self else { return }
      self.presentSynopsisInput()
    }
    
    self.eventManager.onEvent.sinkDisposed(receiveCompletion: nil) { event in
      switch event {
      case StoryDraftModelPresenterEvent.didUpdateStory: self.update()
      default: break
      }
    }

    self.categoryManager.list().sinkDisposed(receiveCompletion: nil) { [weak self] categories in
      self?.categories = categories
      self?.update()
    }
    
    update()
  }

  private func update() {
    guard let model = self.modelPresenter.fetchModel() else { return }
    let story = model.fetchStory()
    if let url = story.portraitImageAsset?.objectUrl {
      portraitUpload.kf.setImage(with: url, for: .normal)
    }
    if let url = story.landscapeImageAsset?.objectUrl {
      landscapeUpload.kf.setImage(with: url, for: .normal)
    }
    titleInput.textView.text = story.title
    categoryInput.textView.text = story.categoryId
      .flatMap({ self.categoryManager.fetchById(categoryId: $0) })?.title
    synopsisInput.textView.text = story.synopsis
  }

  private func presentImagePicker(imageKind: ImageKind) {
    imagePickerAction.apply(self).startWithResult { [weak self] actionResult in
      guard let self = self else { return }
      if case let .success(result) = actionResult {
        switch result {
        case .cancelled:
          break
        case .selected(let image):
          guard let data = image.pngData() else { return }
          switch imageKind {
          case .portrait:
            self.modelPresenter.uploadPortraitAssetForStory(data: data)
          case .landscape:
            self.modelPresenter.uploadLandscapeAssetForStory(data: data)
          }
        }
      }
    }
  }

  override public func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }

  private func presentStoryTitleInput() {
    guard let model = modelPresenter.fetchModel() else { return }
    let vc = TextInputViewController(TextInputViewController.Configuration(
      title: Property<String>(value: "Story Title"),
      initialText: model.fetchStory().title,
      textAttributes: TextAttributes.body14(),
      attributedPlaceholderText: "Fable: The New Beginning".toAttributedString(
        TextAttributes.body14(.fablePlaceholderGray)
      ),
      borderViewModel: FableBorderViewModel.regular
    ))
    vc.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backButton")) { [weak self, weak vc] in
      /// Save on screen dismissal
      if let string = vc?.textView.text {
        self?.modelPresenter.updateStory(parameters: UpdateStoryParameters(title: string))
      }
      vc?.navigationController?.popViewController(animated: true)
    }
    vc.onKeyReturn = { [weak self, weak vc] string in
      guard let self = self else { return }
      self.modelPresenter.updateStory(parameters: UpdateStoryParameters(title: string))
      self.view.layoutIfNeeded()
      vc?.navigationController?.popViewController(animated: true)
    }
    navigationController?.pushViewController(vc, animated: true)
  }

  private func presentCategorySelection() {
    let vc = OptionPickerViewController(OptionPickerViewController.Configuration(
      title: Property<String>(value: "Category"),
      initialSelectionIds: [],
      options: Property<[OptionPickerViewController.Option]>(
        value: self.categories.map { category in
          OptionPickerViewController.Option(
            optionId: "\(category.categoryId)",
            attributedTitle: category.title.toAttributedString(.styled(.fableBlack, font: .fableFont(16.0, weight: .light)))
          )
        }
      )
    ))
    vc.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backButton")) { [weak vc] in
      vc?.navigationController?.popViewController(animated: true)
    }
    vc.selectedOptions.signal.observeValues { [weak self] selectedOptions in
      guard let self = self, let option = selectedOptions.first else { return }
      if let optionId = option.optionId.toIntOrNull() {
        self.modelPresenter.updateStory(parameters: UpdateStoryParameters(categoryId: optionId))
        self.view.layoutIfNeeded()
        self.navigationController?.popViewController(animated: true)
      }
    }
    navigationController?.pushViewController(vc, animated: true)
  }

  private func presentSynopsisInput() {
    guard let model = self.modelPresenter.fetchModel() else { return }
    let vc = TextInputViewController(TextInputViewController.Configuration(
      title: Property<String>(value: "Synopsis"),
      initialText: model.fetchStory().synopsis,
      textAttributes: TextAttributes.body14(),
      attributedPlaceholderText: "It all started when the Fire Nation attacked...".toAttributedString(
        TextAttributes.body14(.fablePlaceholderGray)
      ),
      borderViewModel: FableBorderViewModel.regular
    ))
    vc.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backButton")) { [weak self, weak vc] in
      /// Save on screen dismissal
      if let string = vc?.textView.text {
        self?.modelPresenter.updateStory(parameters: UpdateStoryParameters(synopsis: string))
      }
      vc?.navigationController?.popViewController(animated: true)
    }
    vc.onKeyReturn = { [weak self, weak vc] string in
      guard let self = self else { return }
      self.modelPresenter.updateStory(parameters: UpdateStoryParameters(synopsis: string))
      self.view.layoutIfNeeded()
      vc?.navigationController?.popViewController(animated: true)
    }
    navigationController?.pushViewController(vc, animated: true)
  }
}

public class ImageUploadView: UIButton {
  public let placeholderImageView = UIImageView()

  public init() {
    super.init(frame: .zero)

    imageView?.contentMode = .scaleAspectFill

    backgroundColor = .fableGray
    layer.cornerRadius = 12.0
    clipsToBounds = true

    placeholderImageView.image = UIImage(named: "cameraIcon")
    placeholderImageView.contentMode = .center

    addSubview(placeholderImageView)

    placeholderImageView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }

    if let imageView = self.imageView {
      imageView.reactive.producer(for: \UIImageView.image).take(duringLifetimeOf: self)
        .startWithValues { [weak self] image in
          self?.placeholderImageView.isHidden = image != nil
        }
    }
  }

  public required init?(coder: NSCoder) {
    fatalError()
  }
}

public class IconTextViewButton: UIButton {
  public let iconImageView = UIImageView()
  public let textLabel = UILabel()
  public let textView = UITextView()
  public let chevron = UIImageView()

  public init(icon: UIImage?, title: String) {
    super.init(frame: .zero)

    addBorder(.bottom, viewModel: FableBorderViewModel.regular)

    layoutMargins = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)

    iconImageView.contentMode = .center
    iconImageView.image = icon
    iconImageView.tintColor = .fableBlack

    textLabel.font = .fableFont(16.0, weight: .light)
    textLabel.textColor = .fableBlack
    textLabel.text = title

    textView.font = .fableFont(16.0, weight: .light)
    textView.textColor = .fableTextGray
    textView.isScrollEnabled = false
    textView.isUserInteractionEnabled = false
    textView.textContainerInset = .zero

    chevron.contentMode = .center
    chevron.image = UIImage(named: "accessoryIcon")
    chevron.tintColor = .fableBlack

    addSubview(iconImageView)
    addSubview(textLabel)
    addSubview(textView)
    addSubview(chevron)

    iconImageView.snp.makeConstraints { make in
      make.centerX.equalTo(snp.leading).offset(24.0)
      make.centerY.equalTo(snp.top).offset(24.0)
    }

    textLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(40.0)
      make.trailing.equalToSuperview().inset(layoutMargins)
      make.centerY.equalTo(iconImageView.snp.centerY)
      make.height.greaterThanOrEqualTo(20.0)
    }

    textView.snp.makeConstraints { make in
      make.leading.equalTo(textLabel).offset(-5.0)
      make.trailing.equalTo(chevron.snp.leading).offset(-8.0)
      make.top.equalTo(textLabel.snp.bottom).offset(8.0)
      make.bottom.equalToSuperview().inset(layoutMargins)
      make.height.greaterThanOrEqualTo(24.0)
    }

    chevron.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(layoutMargins)
      make.centerY.equalToSuperview()
    }

    snp.makeConstraints { make in
      make.height.greaterThanOrEqualTo(60.0)
    }

    setContentHuggingPriority(.defaultHigh, for: .vertical)
    textLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    textView.setContentCompressionResistancePriority(.required, for: .vertical)
  }

  public required init?(coder: NSCoder) {
    fatalError()
  }

  override public func layoutIfNeeded() {
    super.layoutIfNeeded()
  }
}
