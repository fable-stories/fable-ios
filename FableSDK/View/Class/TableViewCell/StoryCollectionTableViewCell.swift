//
//  StoryCollectionTableViewCell.swift
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

public protocol StoryCollectionTableViewCellDelegate: class {
  func storyCollectionTableViewCell(prefetchImageForKey key: String, view: StoryCollectionTableViewCell) -> UIImage?
  func storyCollectionTableViewCell(didRetrieveImage image: UIImage, forKey key: String, view: StoryCollectionTableViewCell)
}

public class StoryCollectionTableViewCell: UITableViewCell {
  public var stories: [Story] = [] {
    didSet {
      carouselView.reloadData()
    }
  }

  public var onStorySelect: ((Story) -> Void)?
  
  public weak var delegate: StoryCollectionTableViewCellDelegate?

  override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    configureSelf()
    configureLayout()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  private let carouselView = CarouselView(
    itemSize: StoryContainerView.size,
    itemSpacing: 16.0,
    isInfinite: false
  )

  private func configureSelf() {
    carouselView.delegate = self
    contentView.backgroundColor = .clear
    backgroundColor = .clear
    selectionStyle = .none
  }

  private func configureLayout() {
    contentView.addSubview(carouselView)

    carouselView.snp.makeConstraints { make in
      make.edges.equalTo(contentView.snp.edges)
      make.height.equalTo(StoryContainerView.size.height)
    }
  }
}

extension StoryCollectionTableViewCell: CaraouselViewDelegate {
  public func carouselView(_ carouselView: CarouselView, numberOfItemsIn collectionView: UICollectionView) -> Int {
    stories.count
  }

  public func carouselView(_ carouselView: CarouselView, collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
    let cell = collectionView.dequeueReusableCell(for: StoryContainerCollectionViewCell.self, at: indexPath)
    cell.delegate = self
    let story = stories[indexPath.row]
    cell.story = story
    cell.storyContainerView.selectionContainer.reactive.pressed = .invoke { [weak self] in
      self?.onStorySelect?(story)
    }
    return cell
  }
}

extension StoryCollectionTableViewCell: StoryContainerCollectionViewCellDelegate {
  public func storyContainerCollectionViewCell(prefetchImageForKey key: String, view: StoryContainerCollectionViewCell) -> UIImage? {
    self.delegate?.storyCollectionTableViewCell(prefetchImageForKey: key, view: self)
  }
  
  public func storyContainerCollectionViewCell(didRetrieveImage image: UIImage, forKey key: String, view: StoryContainerCollectionViewCell) {
    self.delegate?.storyCollectionTableViewCell(didRetrieveImage: image, forKey: key, view: self)
  }
}
