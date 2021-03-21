//
//  StoryContainerView.swift
//  Fable
//
//  Created by Andrew Aquino on 8/26/19.
//

import AppFoundation
import AppUIFoundation
import FableSDKModelObjects
import ReactiveSwift
import SnapKit
import UIKit
import Kingfisher

public protocol StoryContainerViewDelegate: class {
  func storyContainerView(prefetchImageForKey key: String, view: StoryContainerView) -> UIImage?
  func storyContainerView(didRetrieveImage image: UIImage, forKey key: String, view: StoryContainerView)
}

public class StoryContainerView: UIView {
  public static let size = CGSize(width: 113.0, height: 217.0)
  
  public enum Stat {
    case views(Int)
    case likes(Int)
    
    public var imageName: String {
      switch self {
      case .likes: return "heart"
      case .views: return "eye"
      }
    }
    
    public var value: Int {
      switch self {
      case let .likes(value): return value
      case let .views(value): return value
      }
    }
    
    public var displayString: String {
      let k = value / 1000
      let h = value % 1000
      if k == 0 { return "\(value)" }
      return "\(k).\(h)k"
    }
  }

  public var story: Story? {
    didSet {
      updateView()
    }
  }

  public weak var delegate: StoryContainerViewDelegate?

  public init(delegate: StoryContainerViewDelegate? = nil) {
    self.delegate = delegate
    super.init(frame: .zero)
    configureSelf()
    configureLayout()
    configureReactive()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError()
  }
  
  private let storyImageContainer: UIView = .new { view in
    view.layer.cornerRadius = 12.0
    view.layer.masksToBounds = true
    view.layer.borderWidth = 1.0
    view.layer.borderColor = UIColor.clear.cgColor
  }

  private let storyImageView = UIButton.new {
    $0.contentMode = .scaleAspectFill
  }
  
  private let statsContainer: UIStackView = .new { view in
    view.axis = .horizontal
    view.alignment = .center
    view.distribution = .fillEqually
  }
  
  private lazy var viewsButton: UIButton = .new { button in
    button.setImage(
      UIImage(named: Stat.views(0).imageName)?
        .resized(to: .init(width: 13.0, height: 11.0)),
      for: .normal
    )
    button.imageView?.contentMode = .scaleAspectFit
    button.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 6.0)
  }
  
  private lazy var likesButton: UIButton = .new { button in
    button.setImage(
      UIImage(named: Stat.likes(0).imageName)?
        .resized(to: .init(width: 12.0, height: 11.0)),
      for: .normal
    )
    button.imageView?.contentMode = .scaleAspectFit
    button.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 6.0)
  }
  
  private let titleLabel = UILabel.new {
    $0.numberOfLines = 2
    $0.setTextAttributes(.titleBold14(UIColor("#173966")))
  }

  private lazy var gradentView: GradientView = {
    let view = GradientView(
      start: GradientView.ViewModel(color: .clear, point: CGPoint(x: 0.5, y: 1.0)),
      end: GradientView.ViewModel(color: .fableBlack, point: CGPoint(x: 0.5, y: 0.0)),
      alpha: 0.6
    )
    view.isHidden = true
    return view
  }()
  
  public let selectionContainer = UIButton()

  private func configureSelf() {
    backgroundColor = .clear
  }

  private func configureLayout() {
    self.addSubview(storyImageContainer)
    storyImageContainer.addSubview(storyImageView)
    storyImageContainer.addSubview(gradentView)
    addSubview(statsContainer)
    statsContainer.addArrangedSubview(viewsButton)
    statsContainer.addArrangedSubview(likesButton)
    addSubview(titleLabel)
    addSubview(selectionContainer)

    storyImageContainer.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.size.equalTo(CGSize(width: 113.0, height: 155.0))
    }
    
    storyImageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    gradentView.snp.makeConstraints { make in
      make.edges.equalTo(snp.edges)
    }
    
    statsContainer.snp.makeConstraints { make in
      make.top.equalTo(storyImageView.snp.bottom).offset(6.0)
      make.leading.equalTo(snp.leadingMargin)
      make.trailing.equalTo(snp.trailingMargin)
    }

    titleLabel.snp.makeConstraints { make in
      make.top.equalTo(statsContainer.snp.bottom)
      make.leading.equalTo(snp.leadingMargin)
      make.trailing.equalTo(snp.trailingMargin)
      make.bottom.equalTo(snp.bottomMargin)
    }

    selectionContainer.snp.makeConstraints { make in
      make.edges.equalTo(snp.edges)
    }
  }

  private func configureReactive() {}

  private func updateView() {
    guard let story = story else {
      titleLabel.text = nil
      gradentView.isHidden = true
      return
    }
    titleLabel.text = story.title
    
    let key = "story_id_\(story.storyId)__square_image_url"
    if let image = self.delegate?.storyContainerView(prefetchImageForKey: key, view: self) {
      self.gradentView.isHidden = false
      self.storyImageView.setImage(image, for: .normal)
    } else {
      self.storyImageView.kf.setImage(
        /// TODO: remove back support for square image asset here
        with: story.portraitImageAsset?.objectUrl ?? story.squareImageAsset?.objectUrl,
        for: .normal,
        placeholder: UIImage(named: "fable_story_placeholder_white"),
        options: [
          .cacheMemoryOnly
        ],
        progressBlock: nil
      ) { [weak self] result in
        guard let self = self else { return }
        switch result {
        case .failure(let error):
          print(error)
        case .success(let imageResult):
          let image = imageResult.image
          self.gradentView.isHidden = false
          self.delegate?.storyContainerView(didRetrieveImage: image, forKey: key, view: self)
        }
      }
    }
    
    let likes: Stat = .likes(story.stats.likes)
    self.likesButton.setAttributedTitle(likes.displayString.toAttributedString([
      .foregroundColor: UIColor.black
    ]), for: .normal)

    let views: Stat = .likes(story.stats.views)
    self.viewsButton.setAttributedTitle(views.displayString.toAttributedString([
      .foregroundColor: UIColor.black
    ]), for: .normal)
  }
  
  public func prepareForReuse() {
    self.gradentView.isHidden = true
    self.storyImageView.setImage(nil, for: .normal)
  }
}
