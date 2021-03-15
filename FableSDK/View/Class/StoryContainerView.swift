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

  private let titleLabel = UILabel.new {
    $0.numberOfLines = 0
    $0.setTextAttributes(.titleBold14(.white))
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
    backgroundColor = .random()
  }

  private func configureLayout() {
    self.addSubview(storyImageContainer)
    storyImageContainer.addSubview(storyImageView)
    storyImageContainer.addSubview(gradentView)
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

    titleLabel.snp.makeConstraints { make in
      make.top.equalTo(storyImageView.snp.bottom).offset(6.0)
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
  }
  
  public func prepareForReuse() {
    self.gradentView.isHidden = true
    self.storyImageView.setImage(nil, for: .normal)
  }
}
