//
//  UserProfileNode+TableNode.swift
//  FableSDKViews
//
//  Created by Andrew Aquino on 12/27/20.
//

import Foundation
import AsyncDisplayKit
import Kingfisher

extension UserProfileNode: ASTableDataSource, ASTableDelegate {
  public func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    sortedSections.count
  }
  
  public func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
    let section = self.sortedSections[indexPath.row]
    let size = tableNode.constrainedSizeForCalculatedLayout.max
    return { [weak self] in
      switch section {
      case .header(let viewModel):
        let node = UserProfileHeaderNode(
          viewModel: .init(
            userId: viewModel.userId,
            avatarAsset: {
              if let key = viewModel.avatarURL?.absoluteStringByTrimmingQuery,
                 let image = ImageCache.default.retrieveImageInMemoryCache(forKey: key) {
                return image
              }
              return viewModel.avatarURL
            }(),
            userName: viewModel.userName,
            biography: viewModel.biography,
            followCount: viewModel.followCount,
            followerCount: viewModel.followerCount,
            storyCount: viewModel.storyCount,
            isFollowing: viewModel.isFollowing,
            isMyUser: viewModel.isMyUser
          )
        )
        node.style.minWidth = .init(unit: .points, value: size.width)
        node.style.minHeight = .init(unit: .points, value: size.height * 0.5)
        node.delegate = self
        let cell = ASWrapperCell(child: node)
        return cell
      case .draftStories(let stories):
        let stories : [StoryCategoryNode.StoryViewModel] = stories.map { story in
          StoryCategoryNode.StoryViewModel(
            storyId: story.storyId,
            title: story.title,
            portraitAsset: story.portraitAsset
          )
        }
        let viewModel: StoryCategoryNode.ViewModel = .init(
          title: "Draft Stories",
          subtitle: "Your works in progress",
          stories: stories
        )
        let node = StoryCategoryNode(viewModel: viewModel)
        node.style.minWidth = .init(unit: .points, value: size.width)
        node.style.minHeight = .init(unit: .points, value: size.height * 0.5)
        node.delegate = self
        let cell = ASWrapperCell(child: node)
        return cell
      case .publishedStories(let stories):
        let stories : [StoryCategoryNode.StoryViewModel] = stories.map { story in
          StoryCategoryNode.StoryViewModel(
            storyId: story.storyId,
            title: story.title,
            portraitAsset: story.portraitAsset
          )
        }
        let viewModel: StoryCategoryNode.ViewModel = .init(
          title: "Published Stories",
          subtitle: "Works created by this author",
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
