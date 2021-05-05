//
//  StoryCollectionNode.swift
//  FableSDKViews
//
//  Created by Andrew Aquino on 12/27/20.
//

import Foundation
import AsyncDisplayKit
import FableSDKInterface

private let textColor: UIColor = .init("#173966")

public protocol StoryCollectionNodeDelegate: class {
  func storyCollectionNode(didSelectStory storyId: Int)
}

public class StoryCollectionNode: ASCollectionNode {
  public struct StoryViewModel {
    public let storyId: Int, title: String, portraitAsset: AssetProtocol?
    
    public init(storyId: Int, title: String, portraitAsset: AssetProtocol?) {
      self.storyId = storyId
      self.title = title
      self.portraitAsset = portraitAsset
    }
  }
  
  public weak var storyDelegate: StoryCollectionNodeDelegate?
  
  public var viewModels: [StoryViewModel] {
    didSet {
      ASPerformBlockOnMainThread {
        self.reloadData()
      }
    }
  }
  
  public init(viewModels: [StoryViewModel]) {
    self.viewModels = viewModels
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 0.0
    layout.minimumLineSpacing = 20.0
    layout.scrollDirection = .horizontal
    super.init(frame: .zero, collectionViewLayout: layout, layoutFacilitator: nil)
    self.delegate = self
    self.dataSource = self
    self.contentInset = .init(top: 0.0, left: 16.0, bottom: 0.0, right: 0.0)
    self.clipsToBounds = false
  }
}

extension StoryCollectionNode: ASCollectionDelegate, ASCollectionDataSource {
  public func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    return viewModels.count
  }
  
  public func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    let viewModel = self.viewModels[indexPath.row]
    let bounds = collectionNode.bounds
    return {
      let node = StoryItemNode()
      node.viewModel = viewModel
      node.style.preferredSize = .init(width: 100.0, height: bounds.height)
      return node
    }
  }
  
  public func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
    let viewModel = self.viewModels[indexPath.row]
    self.storyDelegate?.storyCollectionNode(didSelectStory: viewModel.storyId)
  }
  
  public class StoryItemNode: ASCellNode {
    private static let defaultSize: CGSize = .init(width: 100.0, height: 150.0)
    
    private lazy var backgroundImage: ASNetworkImageNode = .new {
      let node = ASNetworkImageNode()
      node.contentMode = .scaleAspectFill
      node.shadowColor = UIColor.black.cgColor
      node.shadowOffset = .init(width: 0.0, height: 5.0)
      node.shadowRadius = 20.0
      node.shadowOpacity = 0.15
      node.clipsToBounds = false
      node.imageModificationBlock = RoundedCornersModificationBlock(cornerRadius: 16.0)
      node.backgroundColor = .fableLightGray
      return node
    }
    
    private lazy var titleLabel: ASTextNode = .new {
      let node = ASTextNode()
      return node
    }
    
    public var viewModel: StoryViewModel? {
      didSet {
        ASPerformBlockOnMainThread {
          self.updateView()
        }
      }
    }
    
    public override init() {
      super.init()
      self.automaticallyManagesSubnodes = true
      self.clipsToBounds = false
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
      self.backgroundImage.style.preferredSize = StoryItemNode.defaultSize
      
      return ASStackLayoutSpec(
        direction: .vertical,
        spacing: 10.0,
        justifyContent: .start,
        alignItems: .center,
        children: [
          backgroundImage,
          titleLabel
        ]
      )
    }
    
    public override func nodeDidLayout() {
      super.nodeDidLayout()
    }
    
    public func updateView() {
      guard let viewModel = viewModel else { return }
      let placeholderImage = UIImage(named: "fable_story_placeholder_white")
      if let portraitAsset = viewModel.portraitAsset {
        if let image = portraitAsset.image() {
          self.backgroundImage.image = image
        } else if let url = portraitAsset.url() {
          self.backgroundImage.url = url
        }
      } else {
        self.backgroundImage.image = placeholderImage
      }
      self.titleLabel.attributedText = viewModel.title.toAttributedString([
        .font: UIFont.systemFont(ofSize: 14.0, weight: .bold),
        .foregroundColor: textColor
      ])
    }
  }
}
