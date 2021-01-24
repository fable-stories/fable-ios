//
//  StoryEditorSettingsNode.swift
//  FableSDKViews
//
//  Created by Andrew Aquino on 12/14/20.
//

import Foundation
import AsyncDisplayKit
import FableSDKModelObjects

public enum Option: Hashable {
  case showDetails
  case unpublishStory
  case publishStory
  case deleteStory
  case previewStory
  
  fileprivate var sortOrder: Int {
    switch self {
    case .showDetails: return 0
    case .previewStory: return 1
    case .unpublishStory: return 2
    case .publishStory: return 2
    case .deleteStory: return 3
    }
  }
  
  fileprivate var formalTitleString: String {
    switch self {
    case .showDetails: return "Show Story Details"
    case .previewStory: return "Preview Story"
    case .unpublishStory: return "Unpublish Story"
    case .publishStory: return "Publish Story"
    case .deleteStory: return "Delete Story"
    }
  }
}

public protocol StoryEditorSettingsNodeDelegate: class {
  func storyEditorSettingsNode(handleOption option: Option, node: StoryEditorSettingsNode)
}

public class StoryEditorSettingsNode: ASDisplayNode {

  private lazy var options: Set<Option> = [
    .showDetails,
    .previewStory,
    .deleteStory
  ]
  
  private var sortedOptions: [Option] {
    options.sorted(by: { $0.sortOrder < $1.sortOrder })
  }
  
  private lazy var optionsTableNode: ASTableNode = .new {
    let node = ASTableNode()
    node.delegate = self
    node.dataSource = self
    node.view.separatorStyle = .none
    return node
  }
  
  public weak var delegate: StoryEditorSettingsNodeDelegate?

  public override init() {
    super.init()
    self.automaticallyManagesSubnodes = true
    self.backgroundColor = .white
  }
  
  public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    return ASWrapperLayoutSpec(layoutElement: optionsTableNode)
  }
  
  public func setPublishState(_ isPublished: Bool) {
    if isPublished {
      self.options.insert(.unpublishStory)
      self.options.remove(.publishStory)
    } else {
      self.options.insert(.publishStory)
      self.options.remove(.unpublishStory)
    }
  }

  public func reloadData() {
    self.optionsTableNode.reloadData()
  }
  
  private func handleOptionTap(_ option: Option) {
    self.delegate?.storyEditorSettingsNode(handleOption: option, node: self)
  }
}

extension StoryEditorSettingsNode: ASTableDelegate, ASTableDataSource {
  public func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    sortedOptions.count
  }
  
  public func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
    let option = sortedOptions[indexPath.row]
    return {
      let node = OptionCellNode()
      node.setOption(option)
      return node
    }
  }
  
  public func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
    tableNode.deselectRow(at: indexPath, animated: true)
    self.handleOptionTap(sortedOptions[indexPath.row])
  }
}

private class OptionCellNode: ASCellNode {
  
  public private(set) var option: Option?
  
  private lazy var titleLabel: ASTextNode = .new {
    let node = ASTextNode()
    return node
  }

  override init() {
    super.init()
    self.automaticallyManagesSubnodes = true
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    return ASInsetLayoutSpec(
      insets: .init(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0),
      child: titleLabel
    )
  }
  
  public func setOption(_ option: Option) {
    self.option = option
    self.titleLabel.attributedText = option.formalTitleString.toAttributedString([
      .font: UIFont.systemFont(ofSize: 14.0, weight: .regular)
    ])
  }
}
