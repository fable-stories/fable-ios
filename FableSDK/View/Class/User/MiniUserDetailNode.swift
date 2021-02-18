//
//  MiniUserDetailNode.swift
//  FableSDKViews
//
//  Created by Andrew Aquino on 12/28/20.
//

import Foundation
import AsyncDisplayKit
import AppFoundation
import FableSDKInterface

private let textColor: UIColor = .init("#173966")

public protocol MiniUserDetailNodeDelegate: class {
  func miniUserDetailNode(didSelectUser userId: Int)
  func miniUserDetailNode(didSelectFollowButton followButton: FBSDKFollowButton, userId: Int, isFollowing: Bool)
}

public final class MiniUserDetailNode: ASControlNode {
  public struct ViewModel {
    public let userId: Int
    public var avatarAsset: AssetProtocol?
    public var userName: String
    public var isFollowing: Bool?
    public init(userId: Int, avatarAsset: AssetProtocol?, userName: String, isFollowing: Bool?) {
      self.userId = userId
      self.avatarAsset = avatarAsset
      self.userName = userName
      self.isFollowing = isFollowing
    }
  }
  
  public private(set) var viewModel: ViewModel?
  
  public weak var delegate: MiniUserDetailNodeDelegate?
  
  public init(viewModel: ViewModel? = nil) {
    super.init()
    self.automaticallyManagesSubnodes = true
    self.isUserInteractionEnabled = true
    self.setViewModel(viewModel)
  }
  
  private lazy var avatarImage: ASNetworkImageNode = .new {
    let node = ASNetworkImageNode()
    node.imageModificationBlock = RoundedCornersModificationBlock(cornerRadius: 44.0 / 4.0)
    node.addTarget(self, action: #selector(didSelectUser), forControlEvents: .touchUpInside)
    node.addShadow()
    node.image = UIImage(.fableLightGray, size: .sizeWithConstantDimensions(44.0))
    node.isHidden = true
    return node
  }
  
  private lazy var userNameLabel: ASTextNode = .new {
    let node = ASTextNode()
    return node
  }
  
  private lazy var followButton: FBSDKFollowButton = .new {
    let node = FBSDKFollowButton()
    node.addTarget(self, action: #selector(didSelectFollowButton), forControlEvents: .touchUpInside)
    return node
  }
  
  public func setViewModel(_ viewModel: ViewModel?) {
    let avatarPlaceholderImage = UIImage(.fableLightGray, size: .sizeWithConstantDimensions(44.0))
    self.viewModel = viewModel
    guard let viewModel = viewModel else { return }
    if let url = viewModel.avatarAsset?.url() {
      self.avatarImage.setImage(url: url, placeholderImage: avatarPlaceholderImage)
    } else {
      self.avatarImage.image = UIImage(.fableLightGray, size: .sizeWithConstantDimensions(44.0))
    }
    self.userNameLabel.attributedText = viewModel.userName
      .mapTo({ $0.isEmpty ? "User" : $0 })
      .toAttributedString([
        .font: UIFont.systemFont(ofSize: 14.0, weight: .regular),
        .foregroundColor: textColor
      ])
    if let isFollowing = viewModel.isFollowing {
      self.followButton.isFollowing = isFollowing
    }
    self.transitionLayout(withAnimation: false, shouldMeasureAsync: true, measurementCompletion: nil)
    self.avatarImage.isHidden = false
  }
  
  public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    self.avatarImage.style.preferredSize = .sizeWithConstantDimensions(44.0)

    let stack = ASStackLayoutSpec(
      direction: .horizontal,
      spacing: 12.0,
      justifyContent: .start,
      alignItems: .center,
      children: [
        avatarImage,
        ASStackLayoutSpec(
          direction: .vertical,
          spacing: 4.0,
          justifyContent: .spaceBetween,
          alignItems: .start,
          children: [
            userNameLabel,
            self.viewModel?.isFollowing != nil ? followButton : nil
          ].mapNotNil()
        )
      ]
    )
    return ASInsetLayoutSpec(
      insets: .zero,
      child: stack
    )
  }
  
  @objc private func didSelectUser() {
    guard let viewModel = viewModel else { return }
    self.delegate?.miniUserDetailNode(didSelectUser: viewModel.userId)
  }
  
  @objc private func didSelectFollowButton() {
    guard let viewModel = viewModel, let isFollowing = viewModel.isFollowing else { return }
    self.delegate?.miniUserDetailNode(
      didSelectFollowButton: followButton,
      userId: viewModel.userId,
      isFollowing: isFollowing
    )
  }
}
