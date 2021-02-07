//
//  UserProfileHeaderNode.swift
//  FableSDKViews
//
//  Created by Andrew Aquino on 12/27/20.
//

import Foundation
import AsyncDisplayKit
import FableSDKInterface
import AppFoundation

private let textColor: UIColor = .init("#173966")

public protocol UserProfileHeaderNodeDelegate: class {
  func userProfileHeaderNode(didTapFollowersCount node: UserProfileHeaderNode)
  func userProfileHeaderNode(didTapFollowingCount node: UserProfileHeaderNode)
  func userProfileHeaderNode(didTapFollowButton followButton: FBSDKFollowButton, node: UserProfileHeaderNode, userId: Int, isFollowing: Bool)
}

public class UserProfileHeaderNode: ASDisplayNode {
  public struct ViewModel {
    public let userId: Int
    public let avatarAsset: AssetProtocol?
    public let userName: String
    public let biography: String
    public let followCount: Int
    public let followerCount: Int
    public let storyCount: Int
    public let isFollowing: Bool?
    public let isMyUser: Bool
    public init(
      userId: Int,
      avatarAsset: AssetProtocol?,
      userName: String?,
      biography: String?,
      followCount: Int?,
      followerCount: Int?,
      storyCount: Int?,
      isFollowing: Bool?,
      isMyUser: Bool
    ) {
      self.userId = userId
      self.avatarAsset = avatarAsset
      self.userName = userName ?? ""
      self.biography = biography ?? ""
      self.followCount = followCount ?? 0
      self.followerCount = followerCount ?? 0
      self.storyCount = storyCount ?? 0
      self.isFollowing = isFollowing
      self.isMyUser = isMyUser
    }
  }
  
  public weak var delegate: UserProfileHeaderNodeDelegate?
  
  public private(set) var viewModel: ViewModel?
  
  public init(viewModel: ViewModel) {
    super.init()
    self.automaticallyManagesSubnodes = true
    self.isUserInteractionEnabled = true
    self.updateWithViewModel(viewModel)
  }
  
  private lazy var avatarImage: ASNetworkImageNode = .new {
    let node = ASNetworkImageNode()
    node.cornerRoundingType = .precomposited
    node.shadowColor = UIColor.black.cgColor
    node.shadowOffset = .init(width: 0.0, height: 5.0)
    node.shadowRadius = 20.0
    node.shadowOpacity = 0.15
    node.clipsToBounds = false
    node.contentMode = .scaleAspectFill
    node.image = UIImage(.fableLightGray, size: .sizeWithConstantDimensions(44.0))
    return node
  }

  private lazy var userNameLabel: ASTextNode = .new {
    let node = ASTextNode()
    return node
  }

  private lazy var biographyLabel: ASTextNode = .new {
    let node = ASTextNode()
    node.maximumNumberOfLines = 3
    return node
  }
  
  private lazy var followButton: FBSDKFollowButton = .new {
    let node = FBSDKFollowButton()
    node.addTarget(self, action: #selector(didTapFollowButton), forControlEvents: .touchUpInside)
    return node
  }
  
  private lazy var followCountTitleLabel: ASTextNode = .new {
    let node = ASTextNode()
    node.attributedText = "Following".toAttributedString([
      .font: UIFont.systemFont(ofSize: 12.0, weight: .medium),
      .foregroundColor: textColor,
    ])
    return node
  }
  
  private lazy var followCountLabel: ASTextNode = .new {
    let node = ASTextNode()
    return node
  }
  
  private lazy var followerCountTitleLabel: ASTextNode = .new {
    let node = ASTextNode()
    node.attributedText = "Followers".toAttributedString([
      .font: UIFont.systemFont(ofSize: 12.0, weight: .medium),
      .foregroundColor: textColor,
    ])
    return node
  }
  
  private lazy var followerCountLabel: ASTextNode = .new {
    let node = ASTextNode()
    return node
  }
  
  private lazy var storyCountTitleLabel: ASTextNode = .new {
    let node = ASTextNode()
    node.attributedText = "Stories".toAttributedString([
      .font: UIFont.systemFont(ofSize: 12.0, weight: .medium),
      .foregroundColor: textColor,
    ])
    return node
  }
  
  private lazy var storyCountLabel: ASTextNode = .new {
    let node = ASTextNode()
    return node
  }

  public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let avatarDimension: CGFloat = 100.0
    
    self.avatarImage.style.preferredSize = .sizeWithConstantDimensions(avatarDimension)
    self.avatarImage.cornerRadius = avatarDimension / 4.0
    
    let followersButton = ASButtonWrapperNode(
      child: ASCenterLayoutSpec(
        centeringOptions: .X,
        sizingOptions: .minimumX,
        child: ASStackLayoutSpec(
          direction: .vertical,
          spacing: 4.0,
          justifyContent: .center,
          alignItems: .center,
          children: [
            followerCountLabel,
            followerCountTitleLabel,
          ]
        )
      ),
      insets: .insetWithConstantEdges(8.0)
    )
    followersButton.addTarget(self, action: #selector(didTapFollowersButton), forControlEvents: .touchUpInside)
    
    let followingButton = ASButtonWrapperNode(
      child: ASCenterLayoutSpec(
        centeringOptions: .X,
        sizingOptions: .minimumX,
        child: ASStackLayoutSpec(
          direction: .vertical,
          spacing: 4.0,
          justifyContent: .center,
          alignItems: .center,
          children: [
            followCountLabel,
            followCountTitleLabel,
          ]
        )
      ),
      insets: .insetWithConstantEdges(8.0)
    )
    followingButton.addTarget(self, action: #selector(didTapFollowingButton), forControlEvents: .touchUpInside)
    
    let storyCountButton = ASButtonWrapperNode(
      child: ASCenterLayoutSpec(
        centeringOptions: .X,
        sizingOptions: .minimumX,
        child: ASStackLayoutSpec(
          direction: .vertical,
          spacing: 4.0,
          justifyContent: .center,
          alignItems: .center,
          children: [
            storyCountLabel,
            storyCountTitleLabel
          ]
        )
      ),
      insets: .insetWithConstantEdges(8.0)
    )

    return ASStackLayoutSpec(
      direction: .vertical,
      spacing: 0.0,
      justifyContent: .start,
      alignItems: .stretch,
      children: [
        ASInsetLayoutSpec(
          insets: .init(top: 30.0, left: 16.0, bottom: 0.0, right: 16.0),
          child: ASCenterLayoutSpec(centeringOptions: .X, sizingOptions: .minimumX, child: avatarImage)
        ),
        ASInsetLayoutSpec(
          insets: .init(top: 12.0, left: 20.0, bottom: 0.0, right: 20.0),
          child: ASCenterLayoutSpec(centeringOptions: .X, sizingOptions: .minimumX, child: userNameLabel)
        ),
        self.viewModel?.isFollowing == nil ? nil : ASInsetLayoutSpec(
          insets: .init(top: 12.0, left: 20.0, bottom: 0.0, right: 20.0),
          child: ASCenterLayoutSpec(centeringOptions: .X, sizingOptions: .minimumX, child: followButton)
        ),
        ASInsetLayoutSpec(
          insets: .init(top: 12.0, left: 35.0, bottom: 0.0, right: 35.0),
          child: ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 0.0,
            justifyContent: .spaceBetween,
            alignItems: .center,
            children: [
              followersButton,
              ASDisplayNode().also { node in
                node.backgroundColor = textColor
                node.style.preferredSize = .init(width: 1.0, height: 18.0)
              },
              storyCountButton,
              ASDisplayNode().also { node in
                node.backgroundColor = textColor
                node.style.preferredSize = .init(width: 1.0, height: 18.0)
              },
              followingButton
            ] as [ASDisplayNode]
          )
        ),
        ASInsetLayoutSpec(
          insets: .init(top: 20.0, left: 35.0, bottom: 30.0, right: 35.0),
          child: ASCenterLayoutSpec(centeringOptions: .X, sizingOptions: .minimumX, child: biographyLabel)
        ),
      ].mapNotNil()
    )
  }
  
  public func updateWithViewModel(_ viewModel: ViewModel) {
    let avatarPlaceholderImage = UIImage(.fableLightGray, size: .sizeWithConstantDimensions(44.0))
    self.viewModel = viewModel
    if let image = viewModel.avatarAsset?.image() {
      self.avatarImage.image = image
    } else if let url = viewModel.avatarAsset?.url() {
      self.avatarImage.setImage(url: url, placeholderImage: avatarPlaceholderImage)
    } else {
      self.avatarImage.image = avatarPlaceholderImage
    }
    if viewModel.userName.isNotEmpty {
      self.userNameLabel.attributedText = "@\(viewModel.userName.localizedLowercase)".toAttributedString([
        .font: UIFont.systemFont(ofSize: 16.0, weight: .medium),
        .foregroundColor: textColor,
      ])
    }
    self.biographyLabel.attributedText = viewModel.biography.toAttributedString([
      .font: UIFont.systemFont(ofSize: 14.0, weight: .regular),
      .foregroundColor: textColor,
    ])
    self.followCountLabel.attributedText = "\(viewModel.followCount)".toAttributedString([
      .font: UIFont.systemFont(ofSize: 18.0, weight: .bold),
      .foregroundColor: textColor,
    ])
    self.followerCountLabel.attributedText = "\(viewModel.followerCount)".toAttributedString([
      .font: UIFont.systemFont(ofSize: 18.0, weight: .bold),
      .foregroundColor: textColor,
    ])
    self.storyCountLabel.attributedText = "\(viewModel.storyCount)".toAttributedString([
      .font: UIFont.systemFont(ofSize: 18.0, weight: .bold),
      .foregroundColor: textColor,
    ])
    if let isFollowing = viewModel.isFollowing {
      self.followButton.isFollowing = isFollowing
    }
  }
  
  @objc private func didTapFollowersButton() {
    self.delegate?.userProfileHeaderNode(didTapFollowersCount: self)
  }

  @objc private func didTapFollowingButton() {
    self.delegate?.userProfileHeaderNode(didTapFollowingCount: self)
  }
  
  @objc private func didTapFollowButton() {
    guard let viewModel = viewModel else { return }
    self.delegate?.userProfileHeaderNode(didTapFollowButton: followButton, node: self, userId: viewModel.userId, isFollowing: !followButton.isFollowing)
  }
}

public final class FBSDKFollowButton: FBSDKButtonNode {
  
  public var isFollowing: Bool {
    didSet {
      self.setAttributedTitle((isFollowing ? "Unfollow" : "Follow").toAttributedString([
        .font: UIFont.systemFont(ofSize: 11.0, weight: .regular)
      ]), for: [.normal, .highlighted, .selected])
      self.isSelected = isFollowing
    }
  }
  
  public init(isFollowing: Bool = false) {
    self.isFollowing = isFollowing
    super.init(buttonKind: .toggle)
    self.style.preferredSize = .init(width: 80.0, height: 24.0)
  }
}
