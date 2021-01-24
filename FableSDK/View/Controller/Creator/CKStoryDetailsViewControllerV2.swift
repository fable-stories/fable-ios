//
//  StoryDetailsViewControllerV2.swift
//  Fable
//
//  Created by Andrew Aquino on 12/16/19.
//  V2 by Madan U S on 11/17/20.
//

import AppFoundation
import AppUIFoundation
import FableSDKInterface
import FableSDKModelObjects
import FableSDKResourceManagers
import FableSDKResolver
import FableSDKUIFoundation
import FableSDKEnums
import FableSDKModelPresenters
import FableSDKViews
import FableSDKModelManagers
import FableSDKViewPresenters
import Kingfisher
import ReactiveCocoa
import ReactiveSwift
import SnapKit
import UIKit
import AsyncDisplayKit

public enum ImageKind {
  case portrait
  case landscape
}


public class StoryDetailsViewControllerV2: ASDKViewController<StoryDetailNodeV2>, ASEditableTextNodeDelegate {
  private enum ImageKind {
    case square
    case landscape
  }
  
  private enum InputKind {
    case title
    case synopsis
  }
  
  private var categories: [Kategory] = []
  
  private let resolver: FBSDKResolver
  private let categoryManager: CategoryManager
  private let eventManager: EventManager
  private let assetManager: AssetManager
  
  private let modelPresenter: StoryDraftModelPresenter
  
  private let imagePickerAction = ImagePickerViewControllerBuilder.makeImagePickerAction()

  public init(
    resolver: FBSDKResolver,
    workspaceManager: WorkspaceManager
  ) {
    self.resolver = resolver
    self.categoryManager = resolver.get()
    self.eventManager = resolver.get()
    self.assetManager = resolver.get()
    self.modelPresenter = StoryDraftModelPresenterBuilder.make(resolver: resolver)
    super.init(node: .init())
  }
  
  public init(
    resolver: FBSDKResolver,
    modelPresenter: StoryDraftModelPresenter
  ) {
    self.resolver = resolver
    self.categoryManager = resolver.get()
    self.eventManager = resolver.get()
    self.assetManager = resolver.get()
    self.modelPresenter = modelPresenter
    super.init(node: .init())
  }
  
  public required init?(coder: NSCoder) {
    fatalError()
  }

  override public func viewDidLoad() {
    super.viewDidLoad()

    configureSelf()
    
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

  private func configureSelf() {
    self.title = "Story Details"
  }

  private func update() {
    guard let model = self.modelPresenter.fetchModel() else { return }
    let story = model.fetchStory()
    let viewModel = StoryDetailNodeV2.ViewModel.init(
      portraitImageAsset: story.portraitImageAsset?.objectUrl,
      landscapeImageAsset: story.squareImageAsset?.objectUrl,
      title: story.title,
      synopsis: story.synopsis,
      category: story.categoryId.flatMap(self.categoryManager.fetchById(categoryId:))?.title ?? ""
    )
    self.node.updateWithViewModel(viewModel)
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
    vc.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backButton")) { [weak vc] in
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
    vc.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backButton")) { [weak vc] in
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

extension StoryDetailsViewControllerV2: StoryDetailNodeV2Delegate {
  public func storyDetailNode(didSelectCategoryField node: StoryDetailNodeV2) {
    self.presentCategorySelection()
  }
  
  public func storyDetailNode(didSelectPortraitUploadField node: StoryDetailNodeV2) {
  }
  
  public func storyDetailNode(didSelectLandscapUploadField node: StoryDetailNodeV2) {
  }
}

public class ImageUploadViewV3: ASControlNode {
  public let label = ASTextNode()
  public let imageButton = ASNetworkImageNode()
  public var placeholderImageNode = ASNetworkImageNode()
  public var type: ImageKind

  public init(title: String, type: ImageKind) {
    self.type = type
    label.attributedText = NSAttributedString(
    string: title,
    attributes: [
      NSAttributedString.Key.font: UIFont.fableFont(16.0, weight: .semibold),
      NSAttributedString.Key.foregroundColor : UIColor.fableBlack
    ])

    super.init()

    imageButton.contentMode = .scaleAspectFit

    imageButton.backgroundColor = .fableWhite
    imageButton.layer.cornerRadius = 12.0
    clipsToBounds = true

    placeholderImageNode.image = UIImage(named: "UploadImage")
    placeholderImageNode.layer.cornerRadius = 12.0
    placeholderImageNode.contentMode = .center

    automaticallyManagesSubnodes = true
  }

  public required init?(coder: NSCoder) {
    fatalError()
  }

  public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let verticalPadding: CGFloat = 10.0

    // Place the button and placeholder
    let imageButtonLayout = ASOverlayLayoutSpec(child: imageButton, overlay: placeholderImageNode)

    if (type == .portrait) {
      imageButton.style.height = ASDimension(unit: .points, value: 155.0)
      imageButton.style.width = ASDimension(unit: .points, value: 113.0)
    }
    else {
      imageButton.style.height = ASDimension(unit: .points, value: 155.0)
      imageButton.style.width = ASDimension(unit: .points, value: 291.0)
    }

    // Put it in a stack
    let imageUploadViewStack = ASStackLayoutSpec.horizontal()
    imageUploadViewStack.style.flexShrink = 1.0
    imageUploadViewStack.style.flexGrow = 1.0
    imageUploadViewStack.children = [imageButtonLayout]
    
    // Add a label
    let imageUploadViewWithLabelStack = ASStackLayoutSpec.vertical()
    imageUploadViewWithLabelStack.style.flexShrink = 1.0
    imageUploadViewWithLabelStack.style.flexGrow = 1.0
    imageUploadViewWithLabelStack.spacing = verticalPadding
    imageUploadViewWithLabelStack.children = [label, imageUploadViewStack]

    // Inset it
    let insets = UIEdgeInsets(top: verticalPadding, left: 0.0, bottom: 0.0, right: 0.0)
    let insetWrapper = ASInsetLayoutSpec(insets: insets, child: imageUploadViewWithLabelStack)

    return insetWrapper
  }
  
  
  public override func layout() {
    imageButton.shadowOpacity = 0.5
    imageButton.shadowColor = UIColor.fableDarkGray.cgColor
    imageButton.shadowRadius = 8.0
    imageButton.shadowOffset = CGSize(width: 0.0, height: 0.0)

    let shadowOutset = CGFloat(0.0)
    imageButton.layer.shadowPath = UIBezierPath(rect: CGRect(x: -shadowOutset, y: -shadowOutset, width: imageButton.bounds.width + shadowOutset, height : imageButton.bounds.height + shadowOutset)).cgPath
  }
}

public protocol StoryDetailNodeV2Delegate: class {
  func storyDetailNode(didSelectCategoryField node: StoryDetailNodeV2)
  func storyDetailNode(didSelectPortraitUploadField node: StoryDetailNodeV2)
  func storyDetailNode(didSelectLandscapUploadField node: StoryDetailNodeV2)
}

public final class StoryDetailNodeV2: ASScrollNode {
  public struct ViewModel {
    public let portraitImageAsset: AssetProtocol?,
               landscapeImageAsset: AssetProtocol?,
               title: String,
               synopsis: String,
               category: String
    public init(portraitImageAsset: AssetProtocol?, landscapeImageAsset: AssetProtocol?, title: String, synopsis: String, category: String) {
      self.portraitImageAsset = portraitImageAsset
      self.landscapeImageAsset = landscapeImageAsset
      self.title = title
      self.synopsis = synopsis
      self.category = category
    }
  }
  
  public weak var delegate: StoryDetailNodeV2Delegate?
  
  public override init() {
    super.init()
    self.backgroundColor = .fableWhite
    self.automaticallyManagesSubnodes = true
    self.automaticallyManagesContentSize = true
  }
  
  private lazy var portraitUpload: ImageUploadViewV3 = .new {
    let node = ImageUploadViewV3(title: "Cover Image", type: .portrait)
    node.imageButton.addTarget(self, action: #selector(didTapPortraitUploadButton), forControlEvents: .touchUpInside)
    return node
  }
  private lazy var landscapeUpload: ImageUploadViewV3 = .new {
    let node = ImageUploadViewV3(title: "Banner Image", type: .landscape)
    node.imageButton.addTarget(self, action: #selector(didTapLandscapeUploadButton), forControlEvents: .touchUpInside)
    return node
  }

  private lazy var titleInput: FBSDKEditableTextNodeWithLabel = .new {
    let node = FBSDKEditableTextNodeWithLabel(
      title: "Story Title",
      placeholderText: ""
    )
    return node
  }
  
  private lazy var synopsisInput: FBSDKEditableTextNodeWithLabel = .new {
    let node = FBSDKEditableTextNodeWithLabel(
      title: "Synopsis",
      placeholderText: "",
      numberOflines: 3
    )
    return node
  }
  
  private lazy var categoryInput: FBSDKEditableTextNodeWithLabel = .new {
    let node = FBSDKEditableTextNodeWithLabel (
      title: "Category",
      placeholderText: "",
      numberOflines: 1
    )
    return node
  }

  public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let verticalPadding: CGFloat = 10.0
    let horizontalPadding: CGFloat = 10.0
    
    let stack = ASStackLayoutSpec.vertical()
    // Add children to the stack.
    stack.children = [self.portraitUpload, self.landscapeUpload, self.titleInput, self.categoryInput, self.synopsisInput]
    let insets = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    let storyDetailsWithInset = ASInsetLayoutSpec(insets: insets, child: stack)
    
    return storyDetailsWithInset
  }
  
  @objc private func didTapPortraitUploadButton() {
    
  }
  
  @objc private func didTapLandscapeUploadButton() {

  }
  
  public func updateWithViewModel(_ viewModel: ViewModel) {
    if let url = viewModel.portraitImageAsset?.url() {
      portraitUpload.imageButton.url = url
    }
    if let url = viewModel.landscapeImageAsset?.url() {
      landscapeUpload.imageButton.url = url
    }
    titleInput.textField.textView.text = viewModel.title
    synopsisInput.textField.textView.text = viewModel.title
    categoryInput.textField.textView.text = viewModel.category
  }
}
