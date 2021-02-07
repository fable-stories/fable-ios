//
//  FeedViewNode.swift
//  FableSDKViews
//
//  Created by Andrew Aquino on 1/4/21.
//

import Foundation
import AsyncDisplayKit
import FableSDKModelObjects

public protocol FeedNodeDelegate: class {
  func feedNode(didSelectStory storyId: Int)
  func feedNode(didTapBackgroundImage node: FeedNode)
}

public class FeedNode: ASDisplayNode {
  public enum Section: Hashable {
    case category(CategoryViewModel)

    public var sortOrder: Int {
      switch self {
      case .category: return 0
      }
    }
    
    public func hash(into hasher: inout Hasher) {
      hasher.combine(sortOrder)
    }
    
    public struct CategoryViewModel {
      public let category: Kategory
      public let stories: [Story]
      public init(category: Kategory, stories: [Story]) {
        self.category = category
        self.stories = stories
      }
    }

    public static func == (lhs: FeedNode.Section, rhs: FeedNode.Section) -> Bool {
      switch (lhs, rhs) {
      case (.category, .category):
        return true
      }
    }
  }
  
  public var sections: [Section] = [] {
    didSet {
      ASPerformBlockOnMainThread {
        self.tableNode.isHidden = self.sections.isEmpty
        self.tableNode.reloadData()
      }
    }
  }
  
  public var sortedSections: [Section] {
    sections.sorted(by: { $0.sortOrder < $1.sortOrder })
  }
  
  public weak var delegate: FeedNodeDelegate?
  
  private lazy var tableNode: ASTableNode = .new {
    let node = ASTableNode(style: .plain)
    node.delegate = self
    node.dataSource = self
    node.contentInset = .init(top: 0.0, left: 0.0, bottom: 35.0, right: 0.0)
    ASPerformBlockOnMainThread {
      node.view.showsVerticalScrollIndicator = false
      node.view.separatorStyle = .none
    }
    return node
  }
  
  private lazy var placeholderLabel: ASTextNode = .new {
    let node = ASTextNode()
    node.attributedText = "Tap to start a Story!".toAttributedString([
      .font: UIFont.systemFont(ofSize: 12.0, weight: .semibold)
    ])
    return node
  }
  
  private lazy var animationNode: AnimationNode = .new {
    let node = AnimationNode(animationName: "book_search")
    node.animationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapBackgroundImage)))
    return node
  }

  public override init() {
    super.init()
    self.automaticallyManagesSubnodes = true
    self.tableNode.isHidden = true
  }
  
  public override func didEnterDisplayState() {
    super.didEnterDisplayState()
    self.animationNode.play()
  }
  
  public func reloadData() {
    self.tableNode.reloadData()
  }
  
  public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    animationNode.style.preferredSize = .sizeWithConstantDimensions(constrainedSize.max.width)
    return ASOverlayLayoutSpec(
      child: ASStackLayoutSpec(
        direction: .vertical,
        spacing: 8.0,
        justifyContent: .center,
        alignItems: .center,
        children: [
          placeholderLabel,
          animationNode
        ]
      ),
      overlay: ASWrapperLayoutSpec(layoutElement: tableNode)
    )
  }
  
  @objc private func tapBackgroundImage() {
    self.delegate?.feedNode(didTapBackgroundImage: self)
  }
}

extension FeedNode: ASTableDataSource, ASTableDelegate {
  public func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    self.sections.count
  }
  
  public func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
    let section = self.sections[indexPath.row]
    let size = tableNode.constrainedSizeForCalculatedLayout.max
    return {
      switch section {
      case .category(let viewModel):
        let stories : [StoryCategoryNode.StoryViewModel] = viewModel.stories.map { story in
          StoryCategoryNode.StoryViewModel(
            storyId: story.storyId,
            title: story.title,
            /// TODO: remove support for square image
            portraitAsset: story.portraitImageAsset?.objectUrl ?? story.squareImageAsset?.objectUrl
          )
        }
        let viewModel: StoryCategoryNode.ViewModel = .init(
          title: viewModel.category.title,
          subtitle: viewModel.category.subtitle,
          stories: stories
        )
        let node = StoryCategoryNode(viewModel: viewModel)
        node.style.minWidth = .init(unit: .points, value: size.width)
        node.style.minHeight = .init(unit: .points, value: size.height * 0.5)
        node.delegate = self
        let cell = ASWrapperCell(child: node)
        return cell
      }
    }
  }
}

extension FeedNode: StoryCategoryNodeDelegate {
  public func storyCategoryNode(didSelectStory storyId: Int) {
    self.delegate?.feedNode(didSelectStory: storyId)
  }
}
