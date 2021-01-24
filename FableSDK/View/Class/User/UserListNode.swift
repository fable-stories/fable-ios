//
//  UserListNode.swift
//  FableSDKViews
//
//  Created by Andrew Aquino on 12/27/20.
//

import Foundation
import AsyncDisplayKit
import FableSDKInterface

private let textColor: UIColor = .init("#173966")

public protocol UserListNodeDelegate: class {
  func userListNode(didSelectUser userId: Int)
}

public class UserListNode: ASDisplayNode {
  
  public struct UserViewModel {
    public let userId: Int
    public let avatarAsset: AssetProtocol?
    public let userName: String
    public let biography: String
    public let isFollowing: Bool

    public init(
      userId: Int,
      avatarAsset: AssetProtocol?,
      userName: String,
      biography: String,
      isFollowing: Bool
    ) {
      self.userId = userId
      self.avatarAsset = avatarAsset
      self.userName = userName
      self.biography = biography
      self.isFollowing = isFollowing
    }
  }
  
  public var users: [UserViewModel] = [] {
    didSet {
      self.tableNode.reloadData()
    }
  }
  
  public weak var delegate: UserListNodeDelegate?
  
  public override init() {
    super.init()
    self.automaticallyManagesSubnodes = true
  }

  private lazy var tableNode: ASTableNode = .new {
    let node = ASTableNode(style: .plain)
    node.delegate = self
    node.dataSource = self
    node.contentInset = .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0)
    ASPerformBlockOnMainThread {
      node.view.showsVerticalScrollIndicator = false
      node.view.separatorStyle = .none
    }
    return node
  }
  
  public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    return ASWrapperLayoutSpec(layoutElement: tableNode)
  }
}

extension UserListNode: ASTableDelegate, ASTableDataSource {
  public func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    users.count
  }
  
  public func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
    let user = self.users[indexPath.row]
    let size = tableNode.calculatedSize
    return {
      let cell = UserListCell(viewModel: user)
      cell.style.preferredSize = .init(width: size.width, height: 50.0)
      return cell
    }
  }
  
  public func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
    tableNode.deselectRow(at: indexPath, animated: true)
    let user = self.users[indexPath.row]
    self.delegate?.userListNode(didSelectUser: user.userId)
  }
}

extension UserListNode {
  public class UserListCell: ASCellNode {
    
    public let viewModel: UserViewModel

    public init(viewModel: UserViewModel) {
      self.viewModel = viewModel
      super.init()
      self.automaticallyManagesSubnodes = true
      self.updateWithViewModel(viewModel)
    }
    
    private lazy var avatarImage: ASNetworkImageNode = .new {
      let node = ASNetworkImageNode()
      node.contentMode = .scaleAspectFill
      node.imageModificationBlock = RoundedCornersModificationBlock(cornerRadius: 40.0 / 4.0)
      return node
    }
    
    private lazy var titleLabel: ASTextNode = .new {
      let node = ASTextNode()
      return node
    }
    
    private lazy var subtitleLabel: ASTextNode = .new {
      let node = ASTextNode()
      return node
    }
    
    private lazy var followButton: FBSDKFollowButton = .new {
      let node = FBSDKFollowButton()
      return node
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
      self.avatarImage.style.preferredSize = .init(width: 40.0, height: 40.0)
      self.subtitleLabel.style.height = .init(unit: .points, value: 16.0)
      
      let contentSpec = ASInsetLayoutSpec(
        insets: .init(top: 4.0, left: 16.0, bottom: 4.0, right: 16.0),
        child: ASStackLayoutSpec(
          direction: .horizontal,
          spacing: 12.0,
          justifyContent: .spaceBetween,
          alignItems: .center,
          children: [
            ASStackLayoutSpec(
              direction: .horizontal,
              spacing: 12.0,
              justifyContent: .start,
              alignItems: .center,
              children: [
                avatarImage,
                ASStackLayoutSpec(
                  direction: .vertical,
                  spacing: 2.0,
                  justifyContent: .spaceBetween,
                  alignItems: .start,
                  children: [
                    titleLabel,
                    subtitleLabel
                  ]
                ).flexShrink(),
              ]
            ).flexShrink(),
            ASCenterLayoutSpec(
              centeringOptions: .Y,
              sizingOptions: .minimumY,
              child: followButton
            )
          ]
        )
      )
      contentSpec.style.preferredSize = constrainedSize.max
      return contentSpec
    }
    
    public func updateWithViewModel(_ viewModel: UserViewModel) {
      if let image = viewModel.avatarAsset?.image() {
        self.avatarImage.image = image
      } else if let url = viewModel.avatarAsset?.url() {
        self.avatarImage.setImage(url: url)
      } else {
        self.avatarImage.image = UIImage(.fableLightGray, size: .sizeWithConstantDimensions(44.0))
      }
      if viewModel.userName.isEmpty {
        self.titleLabel.attributedText = "User".toAttributedString([
          .font: UIFont.systemFont(ofSize: 16.0, weight: .medium),
          .foregroundColor: textColor,
        ])
      } else {
        self.titleLabel.attributedText = viewModel.userName.toAttributedString([
          .font: UIFont.systemFont(ofSize: 16.0, weight: .medium),
          .foregroundColor: textColor,
        ])
      }
      self.subtitleLabel.attributedText = viewModel.biography.toAttributedString([
        .font: UIFont.systemFont(ofSize: 12.0, weight: .light),
        .foregroundColor: textColor,
      ])
      self.followButton.isFollowing = viewModel.isFollowing
    }
  }
}
