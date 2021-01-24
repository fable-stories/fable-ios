//
//  CharacterControlNode.swift
//  FableSDKViews
//
//  Created by Andrew Aquino on 12/11/20.
//

import Foundation
import AsyncDisplayKit
import FableSDKUIFoundation
import FableSDKModelObjects
import FableSDKEnums

public protocol CharacterControlNodeDelegate: class {
  func characterControlNode(showCharacterList node: CharacterControlNode)
  func characterControlNode(showMoreOptions node: CharacterControlNode)
  func characterControlNode(selectedCharacter characterId: Int)
  func characterControlNode(deselectedCharacter characterId: Int)
}

public class CharacterControlNode: ASDisplayNode {
  
  public var isDisabled: Bool = false {
    didSet {
      showCharacterListButton.isDisabled = isDisabled
    }
  }
  
  private lazy var showCharacterListButton: FBSDKIconButtonNode = .new {
    let node = FBSDKIconButtonNode(primaryColor: UIColor("#1479FF"))
    node.addTarget(self, action: #selector(showCharacterList), forControlEvents: .touchUpInside)
    node.contentMode = .scaleAspectFit
    node.setImage(UIImage(named: "addButtonBlue")?.withRenderingMode(.alwaysTemplate), for: .normal)
    return node
  }
  
  private lazy var collectionNode: ASCollectionNode = .new {
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 10.0
    layout.minimumLineSpacing = 0
    layout.scrollDirection = .horizontal
    let node = ASCollectionNode(collectionViewLayout: layout)
    node.delegate = self
    node.dataSource = self
    return node
  }
  
  private lazy var showMoreOptionsButton: ASButtonNode = .new {
    let node = ASButtonNode()
    node.addTarget(self, action: #selector(showMoreOptions), forControlEvents: .touchUpInside)
    node.setImage(UIImage(named: "menuIconBlack"), for: .normal)
    return node
  }

  public weak var delegate: CharacterControlNodeDelegate?

  private var characters: [Character] = []
  public private(set) var selectedCharacterId: Int?
  
  public override init() {
    super.init()
    self.automaticallyManagesSubnodes = true
    self.clipsToBounds = false

    ASPerformBlockOnMainThread {
      self.view.addBorder(.top, viewModel: FableBorderViewModel.regular)
    }
  }

  public func setCharacters(characters: [Character]) {
    self.characters = characters
    self.collectionNode.reloadData()
  }
  
  public func reloadData() {
    self.collectionNode.reloadData()
  }
  
  public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    self.showCharacterListButton.style.preferredSize = .sizeWithConstantDimensions(36.0)
    self.showMoreOptionsButton.style.preferredSize = .sizeWithConstantDimensions(36.0)
    self.collectionNode.style.height = .init(unit: .points, value: 36.0)

    return ASInsetLayoutSpec(
      insets: .init(top: 10.0, left: 10.0, bottom: 0.0, right: 10.0),
      child: ASStackLayoutSpec(
        direction: .horizontal,
        spacing: 10.0,
        justifyContent: .spaceBetween,
        alignItems: .center,
        children: [
          showCharacterListButton,
          collectionNode.flexGrow(),
          showMoreOptionsButton
        ]
      )
    )
  }
  
  @objc private func showCharacterList() {
    self.delegate?.characterControlNode(showCharacterList: self)
  }

  @objc private func showMoreOptions() {
    self.delegate?.characterControlNode(showMoreOptions: self)
  }
  
  public func setSelectedCharacter(characterId: Int?) {
    self.selectedCharacterId = characterId
    self.reloadData()
  }
}

extension CharacterControlNode: ASCollectionDelegate, ASCollectionDataSource {
  public func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    return self.characters.count
  }
  
  public func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    let character = self.characters[indexPath.row]
    let selectedCharacterId = self.selectedCharacterId
    return {
      let cell = CharacterEditorCell(character: character, selectedCharacterId: selectedCharacterId)
      cell.style.height = .init(unit: .points, value: 30.0)
      return cell
    }
  }
  
  public func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
    if let cell = collectionNode.nodeForItem(at: indexPath) as? CharacterEditorCell {
      let characterId = cell.character.characterId
      if let selectedCharacterId = selectedCharacterId, selectedCharacterId == characterId {
        cell.setSelected(false)
        self.selectedCharacterId = nil
        self.delegate?.characterControlNode(deselectedCharacter: characterId)
      } else {
        cell.setSelected(true)
        self.selectedCharacterId = characterId
        
        NotificationCenter.default.post(StoryEditorNotification.didSelectCharacter(characterId: characterId).notification)

        self.delegate?.characterControlNode(selectedCharacter: characterId)
      }
    }
  }
}

public class CharacterEditorCell: ASCellNode {
  public let character: Character
  
  private lazy var containerNode: InsetNode = .new {
    let node = InsetNode(
      insets: .init(top: 4.0, left: 10.0, bottom: 4.0, right: 10.0),
      child: titleLabel
    )
    return node
  }
  
  private lazy var titleLabel: ASTextNode = .new {
    let node = ASTextNode()
    node.attributedText = character.name.toAttributedString([
      .foregroundColor: UIColor.white,
      .font: UIFont.systemFont(ofSize: 12.0, weight: .regular)
    ])
    return node
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  public init(character: Character, selectedCharacterId: Int?) {
    self.character = character
    super.init()
    self.automaticallyManagesSubnodes = true
    
    self.cornerRadius = 4.0
    self.shadowColor = UIColor.black.cgColor
    self.shadowOpacity = 0.25
    self.shadowRadius = 2.0
    self.shadowOffset = .init(width: 0.0, height: 1.0)
    self.clipsToBounds = false

    self.backgroundColor = character.color
    self.borderWidth = 1.0
    
    self.setSelected(selectedCharacterId == character.characterId)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(didReceiveNotification(_:)),
      name: StoryEditorNotificationName.didSelectCharacter.name,
      object: nil
    )
  }
  
  public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    return ASInsetLayoutSpec(
      insets: .zero,
      child: containerNode
    )
  }
  
  public func setSelected(_ isSelected: Bool) {
    self.borderColor = (isSelected ? UIColor.black : UIColor.clear).cgColor
  }
  
  @objc private func didReceiveNotification(_ notification: Notification) {
    switch notification.name {
    case StoryEditorNotificationName.didSelectCharacter.name:
      let selectedCharacterId = notification.object as? Int
      self.setSelected(selectedCharacterId == character.characterId)
    default:
      break
    }
  }
}
