//
//  StoryCategoryNode.swift
//  FableSDKViews
//
//  Created by Andrew Aquino on 12/27/20.
//

import Foundation
import AsyncDisplayKit
import AppUIFoundation
import FableSDKInterface

private let textColor: UIColor = .init("#173966")
private let subtitleTextColor: UIColor = .init("#949494")

public protocol StoryCategoryNodeDelegate: class {
  func storyCategoryNode(didSelectStory storyId: Int)
}

public class StoryCategoryNode: ASDisplayNode {
  public struct ViewModel {
    public let title: String, subtitle: String, stories: [StoryViewModel]
    public init(title: String, subtitle: String, stories: [StoryViewModel]) {
      self.title = title
      self.subtitle = subtitle
      self.stories = stories
    }
  }
  
  public struct StoryViewModel {
    public let storyId: Int, title: String, portraitAsset: AssetProtocol?
    
    public init(storyId: Int, title: String, portraitAsset: AssetProtocol?) {
      self.storyId = storyId
      self.title = title
      self.portraitAsset = portraitAsset
    }
  }
  
  public weak var delegate: StoryCategoryNodeDelegate?
  
  private var viewModel: ViewModel?

  public init(viewModel: ViewModel?) {
    super.init()
    self.automaticallyManagesSubnodes = true
    self.updateWithViewModel(viewModel)
  }
  
  private lazy var titleLabel: ASTextNode = .new {
    let node = ASTextNode()
    return node
  }
  
  private lazy var subtitleLabel: ASTextNode = .new {
    let node = ASTextNode()
    return node
  }
  
  private lazy var storyCollectionNode: StoryCollectionNode = .new {
    let node = StoryCollectionNode(viewModels: [])
    node.storyDelegate = self
    return node
  }
  
  public func updateWithViewModel(_ viewModel: ViewModel?) {
    self.viewModel = viewModel
    
    guard let viewModel = viewModel else { return }

    self.titleLabel.attributedText = viewModel.title.toAttributedString([
      .font: UIFont.systemFont(ofSize: 16.0, weight: .semibold),
      .foregroundColor: textColor,
      .paragraphStyle: NSMutableParagraphStyle(
        alignment: .left
      )
    ])
    self.subtitleLabel.attributedText = viewModel.subtitle.toAttributedString([
      .font: UIFont.systemFont(ofSize: 12.0, weight: .regular),
      .foregroundColor: subtitleTextColor,
      .paragraphStyle: NSMutableParagraphStyle(
        alignment: .left
      )
    ])
    self.storyCollectionNode.viewModels = viewModel.stories.map { story -> StoryCollectionNode.StoryViewModel in
      .init(storyId: story.storyId, title: story.title, portraitAsset: story.portraitAsset)
    }
  }
  
  public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let size: CGSize = constrainedSize.max
    self.storyCollectionNode.style.height = .init(unit: .points, value: 190.0)
    self.storyCollectionNode.style.width = .init(unit: .points, value: size.width)
    return ASStackLayoutSpec(
      direction: .vertical,
      spacing: 0.0,
      justifyContent: .start,
      alignItems: .stretch,
      children: [
        ASInsetLayoutSpec(
          insets: .init(top: 16.0, left: 16.0, bottom: 4.0, right: 0.0),
          child: titleLabel
        ),
        (self.viewModel.flatMap({ $0.subtitle.isEmpty }) ?? false) ?
          nil
          : ASInsetLayoutSpec(
            insets: .init(top: 0.0, left: 16.0, bottom: 0.0, right: 0.0),
            child: subtitleLabel
          ),
        ASInsetLayoutSpec(
          insets: .init(top: 20.0, left: 0.0, bottom: 30.0, right: 0.0),
          child: storyCollectionNode
        )
      ].compactMap { $0 }
    )
  }
}

extension StoryCategoryNode: StoryCollectionNodeDelegate {
  public func storyCollectionNode(didSelectStory storyId: Int) {
    self.delegate?.storyCategoryNode(didSelectStory: storyId)
  }
}

