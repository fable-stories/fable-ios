//
//  UserProfileNode.swift
//  FableSDKViews
//
//  Created by Andrew Aquino on 12/26/20.
//

import Foundation
import AsyncDisplayKit
import AppFoundation
import FableSDKInterface
import AppUIFoundation
import Kingfisher

extension UIImage: AssetProtocol {}
extension URL: AssetProtocol {}

private let textColor: UIColor = .init("#173966")
private let subtitleTextColor: UIColor = .init("#949494")

public protocol UserProfileNodeDelegate: class {
  func userProfileNode(didSelectStory storyId: Int)
  func userProfileNode(didSelectFollowersCount node: UserProfileNode)
  func userProfileNode(didSelectFollowingCount node: UserProfileNode)
  func userProfileNode(didTapFollowButton followButton: FBSDKFollowButton, node: UserProfileNode, userId: Int, isFollowing: Bool)
  func userProfileNode(didTapBackgroundImage node: UserProfileNode)
}

public class UserProfileNode: ASDisplayNode {
  public enum Section: Hashable {
    case header(HeaderViewModel)
    case draftStories([StoryViewModel])
    case publishedStories([StoryViewModel])
    
    public var sortOrder: Int {
      switch self {
      case .header: return 0
      case .draftStories: return 1
      case .publishedStories: return 2
      }
    }
    
    public func hash(into hasher: inout Hasher) {
      hasher.combine(sortOrder)
    }
    
    public struct HeaderViewModel {
      public let userId: Int
      public let avatarURL: URL?
      public let userName: String
      public let biography: String
      public let followCount: Int
      public let followerCount: Int
      public let storyCount: Int
      public let isFollowing: Bool?
      public let isMyUser: Bool
      public init(
        userId: Int,
        avatarURL: URL?,
        userName: String?,
        biography: String?,
        followCount: Int?,
        followerCount: Int?,
        storyCount: Int?,
        isFollowing: Bool?,
        isMyUser: Bool
      ) {
        self.userId = userId
        self.avatarURL = avatarURL
        self.userName = userName ?? ""
        self.biography = biography ?? ""
        self.followCount = followCount ?? 0
        self.followerCount = followerCount ?? 0
        self.storyCount = storyCount ?? 0
        self.isFollowing = isFollowing
        self.isMyUser = isMyUser
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
    
    public static func == (lhs: UserProfileNode.Section, rhs: UserProfileNode.Section) -> Bool {
      switch (lhs, rhs) {
      case (.header, .header),
           (.draftStories, .draftStories),
           (.publishedStories, .publishedStories):
        return true
      default:
        return false
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

  public weak var delegate: UserProfileNodeDelegate?
  
  private lazy var tableNode: ASTableNode = .new {
    let node = ASTableNode(style: .plain)
    node.delegate = self
    node.dataSource = self
    ASPerformBlockOnMainThread {
      node.view.showsVerticalScrollIndicator = false
      node.view.separatorStyle = .none
    }
    return node
  }
  
  private lazy var placeholderLabel: ASTextNode = .new {
    let node = ASTextNode()
    node.attributedText = "Tap to log in!".toAttributedString([
      .font: UIFont.systemFont(ofSize: 12.0, weight: .semibold)
    ])
    return node
  }
  
  private lazy var animationNode: AnimationNode = .new {
    let node = AnimationNode(animationName: "empty_desk")
    node.animationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapBackgroundImage)))
    node.play()
    return node
  }

  public override init() {
    super.init()
    self.automaticallyManagesSubnodes = true
    self.tableNode.isHidden = true
  }
  
  public func reloadData() {
    self.tableNode.reloadData()
  }

  public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    placeholderLabel.style.height = .init(unit: .points, value: 44.0)
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
    self.delegate?.userProfileNode(didTapBackgroundImage: self)
  }
}

extension UserProfileNode: StoryCategoryNodeDelegate {
  public func storyCategoryNode(didSelectStory storyId: Int) {
    self.delegate?.userProfileNode(didSelectStory: storyId)
  }
}

extension UserProfileNode: UserProfileHeaderNodeDelegate {
  public func userProfileHeaderNode(didTapFollowersCount node: UserProfileHeaderNode) {
    self.delegate?.userProfileNode(didSelectFollowersCount: self)
  }
  
  public func userProfileHeaderNode(didTapFollowingCount node: UserProfileHeaderNode) {
    self.delegate?.userProfileNode(didSelectFollowingCount: self)
  }
  
  public func userProfileHeaderNode(didTapFollowButton followButton: FBSDKFollowButton, node: UserProfileHeaderNode, userId: Int, isFollowing: Bool) {
    self.delegate?.userProfileNode(didTapFollowButton: followButton, node: self, userId: userId, isFollowing: isFollowing)
  }
}
