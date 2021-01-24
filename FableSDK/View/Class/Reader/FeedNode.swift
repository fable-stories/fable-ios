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
  
  public override init() {
    super.init()
    self.automaticallyManagesSubnodes = true
  }
  
  public func reloadData() {
    self.tableNode.reloadData()
  }
  
  public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    return ASWrapperLayoutSpec(layoutElement: tableNode)
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
