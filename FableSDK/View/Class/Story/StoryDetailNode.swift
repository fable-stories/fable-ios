//
//  StoryDetailNode.swift
//  FableSDKViews
//
//  Created by Andrew Aquino on 12/28/20.
//

import Foundation
import AsyncDisplayKit
import FableSDKInterface
import AppFoundation

private let textColor: UIColor = .init("#173966")

public protocol StoryDetailNodeDelegate: class {
  func storyDetailNode(didSelectStartStory storyId: Int)
  func storyDetailNode(didSelectUser userId: Int)
  func storyDetailNode(didSelectFollowButton followButton: FBSDKFollowButton, userId: Int, isFollowing: Bool)
}

public final class StoryDetailNode: ASScrollNode {
  public struct ViewModel {
    public let storyId: Int
    public var miniUserDetail: MiniUserDetailNode.ViewModel
    public var landscapeAsset: AssetProtocol?, title: String, synopsis: String
    public init(
      storyId: Int,
      miniUserDetail: MiniUserDetailNode.ViewModel,
      landscapeAsset: AssetProtocol?,
      title: String,
      synopsis: String
    ) {
      self.storyId = storyId
      self.miniUserDetail = miniUserDetail
      self.landscapeAsset = landscapeAsset
      self.title = title
      self.synopsis = synopsis
    }
  }

  public private(set) var viewModel: ViewModel?
  
  public weak var delegate: StoryDetailNodeDelegate?

  public override init() {
    super.init()
    self.scrollableDirections = [.down, .up]
    self.automaticallyManagesSubnodes = true
    self.backgroundColor = .white
  }

  private lazy var landscapeImage: ASNetworkImageNode = .new {
    let node = ASNetworkImageNode()
    node.imageModificationBlock = RoundedCornersModificationBlock(cornerRadius: 16.0)
    node.addShadow()
    return node
  }
  
  private lazy var titleNode: ASTextNode = .new {
    let node = ASTextNode()
    return node
  }
  
  private lazy var miniUserDetailNode: MiniUserDetailNode = .new {
    let node = MiniUserDetailNode()
    node.delegate = self
    return node
  }
  
  private lazy var synopsisNode: ASTextNode = .new {
    let node = ASTextNode()
    return node
  }
  
  private lazy var startStoryButton: FBSDKButtonNode = .new {
    let node = FBSDKButtonNode(title: "Start Story")
    node.addTarget(self, action: #selector(didSelectStartStory), forControlEvents: .touchUpInside)
    return node
  }

  public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let viewModel = self.viewModel
    let size = constrainedSize.max
    
    let landscapeWidth = size.width - 24.0
    self.landscapeImage.style.preferredSize = CGSize(
      width: landscapeWidth,
      height: landscapeWidth / 2.0
    )
    
    self.startStoryButton.style.preferredSize = .init(width: 248.0, height: 44.0)
    
    return ASStackLayoutSpec(
      direction: .vertical,
      spacing: 0.0,
      justifyContent: .start,
      alignItems: .center,
      children: [
        viewModel?.landscapeAsset != nil ? ASInsetLayoutSpec(
          insets: .insetWithConstantEdges(12.0),
          child: landscapeImage
        ) : nil,
        ASInsetLayoutSpec(
          insets: .init(top: 30.0, left: 16.0, bottom: 25.0, right: 16.0),
          child: titleNode
        ),
        miniUserDetailNode,
        ASInsetLayoutSpec(
          insets: .init(top: 25.0, left: 16.0, bottom: 50.0, right: 16.0),
          child: synopsisNode
        ),
        startStoryButton
      ].compactMap { $0 }
    )
  }
  
  public func setViewModel(_ viewModel: ViewModel) {
    self.viewModel = viewModel
    self.miniUserDetailNode.setViewModel(viewModel.miniUserDetail)
    if let url = viewModel.landscapeAsset?.url() {
      self.landscapeImage.url = url
      self.landscapeImage.isHidden = false
    } else {
      self.landscapeImage.isHidden = true
    }
    self.titleNode.attributedText = viewModel.title.toAttributedString([
      .font: UIFont.systemFont(ofSize: 22.0, weight: .semibold),
      .foregroundColor: UIColor.black
    ])
    self.synopsisNode.attributedText = viewModel.synopsis.toAttributedString([
      .font: UIFont.systemFont(ofSize: 14.0, weight: .medium),
      .foregroundColor: textColor
    ])
  }
  
  @objc private func didSelectStartStory() {
    guard let viewModel = viewModel else { return }
    self.startStoryButton.isSelected = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
      self.startStoryButton.isSelected = false
    })
    self.delegate?.storyDetailNode(didSelectStartStory: viewModel.storyId)
  }
}

extension StoryDetailNode: MiniUserDetailNodeDelegate {
  public func miniUserDetailNode(didSelectUser userId: Int) {
    self.delegate?.storyDetailNode(didSelectUser: userId)
  }
  
  public func miniUserDetailNode(didSelectFollowButton followButton: FBSDKFollowButton, userId: Int, isFollowing: Bool) {
    self.delegate?.storyDetailNode(didSelectFollowButton: followButton, userId: userId, isFollowing: isFollowing)
  }
}
