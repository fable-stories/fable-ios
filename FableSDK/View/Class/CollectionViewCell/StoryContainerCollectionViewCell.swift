//
//  StoryContainerCollectionViewCell.swift
//  Fable
//
//  Created by Andrew Aquino on 8/26/19.
//

import FableSDKModelObjects
import ReactiveSwift
import SnapKit
import UIKit

public protocol StoryContainerCollectionViewCellDelegate: class {
  func storyContainerCollectionViewCell(prefetchImageForKey key: String, view: StoryContainerCollectionViewCell) -> UIImage?
  func storyContainerCollectionViewCell(didRetrieveImage image: UIImage, forKey key: String, view: StoryContainerCollectionViewCell)
}

public class StoryContainerCollectionViewCell: UICollectionViewCell {
  public private(set) lazy var storyContainerView = StoryContainerView(delegate: self)

  public var story: Story? {
    didSet {
      storyContainerView.story = story
    }
  }

  public weak var delegate: StoryContainerCollectionViewCellDelegate?
  
  override public init(frame: CGRect) {
    super.init(frame: frame)
    configureSelf()
    configureLayout()
    configureReactive()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  private func configureSelf() {
    contentView.backgroundColor = .clear
  }

  private func configureLayout() {
    contentView.addSubview(storyContainerView)

    storyContainerView.snp.makeConstraints { make in
      make.edges.equalTo(contentView.snp.edges)
    }
  }

  private func configureReactive() {}
  
  public override func prepareForReuse() {
    super.prepareForReuse()
    self.storyContainerView.prepareForReuse()
  }
}

extension StoryContainerCollectionViewCell: StoryContainerViewDelegate {
  public func storyContainerView(prefetchImageForKey key: String, view: StoryContainerView) -> UIImage? {
    self.delegate?.storyContainerCollectionViewCell(prefetchImageForKey: key, view: self)
  }
  
  public func storyContainerView(didRetrieveImage image: UIImage, forKey key: String, view: StoryContainerView) {
    self.delegate?.storyContainerCollectionViewCell(didRetrieveImage: image, forKey: key, view: self)
  }
}
