//
//  CharacterModifierControlBar.swift
//  Fable
//
//  Created by Andrew Aquino on 12/1/19.
//

import AppFoundation
import FableSDKUIFoundation
import FableSDKModelObjects
import ReactiveSwift
import SnapKit
import UIKit

public class CharacterModifierControlBar: UIView {
  private static let height: CGFloat = 48.0
  private static let iconHeight: CGFloat = 32.0

  public var onCharacterListSelect: VoidClosure?
  
  private var selectedCharacterId: Int?

  public init() {
    super.init(frame: .zero)
    configureSelf()
    configureStackView()
    configureLayout()
    configureReactive()
    configureReactiveDataModel()
  }

  public required init?(coder: NSCoder) {
    fatalError()
  }

  deinit {}

  private lazy var infoLabel = UILabel.create {
    $0.font = .fableFont(11.0, weight: .regular)
    $0.textColor = .fableMediumGray
    $0.text = "Characters"
    $0.tintColor = .fableBlack
  }

  private lazy var addCharacterButton = UIButton.create {
    $0.setImage(UIImage(named: "addCharacterButtonBlack")?.withRenderingMode(.alwaysTemplate), for: .normal)
    $0.tintColor = .fableBlack
    $0.imageView?.contentMode = .scaleAspectFit
    $0.reactive.pressed = .invoke { [weak self] in
      self?.onCharacterListSelect?()
    }
  }

  private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.minimumInteritemSpacing = 5.0
    layout.minimumLineSpacing = 5.0
    return layout
  }()

  public private(set) lazy var collectionView: UICollectionView = {
    let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    view.isPagingEnabled = true
    view.delegate = self
    view.dataSource = self
    view.showsHorizontalScrollIndicator = false
    view.backgroundColor = .clear
    view.clipsToBounds = true
    view.contentInsetAdjustmentBehavior = .always
    return view
  }()

  private let rightControlStackView = UIStackView.create {
    $0.axis = .horizontal
    $0.distribution = .fillProportionally
    $0.spacing = 20.0
    $0.alignment = .center
  }

  private func configureSelf() {
    backgroundColor = .white
  }

  private func configureStackView() {}

  private func configureLayout() {
    layoutMargins = .zero

    addSubview(addCharacterButton)
    addSubview(collectionView)
    addSubview(rightControlStackView)

    addCharacterButton.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(layoutMargins)
      make.centerY.equalTo(collectionView.snp.centerY)
      make.width.equalTo(CharacterModifierControlBar.iconHeight)
      make.height.equalTo(CharacterModifierControlBar.iconHeight)
    }

    collectionView.snp.makeConstraints { make in
      make.leading.equalTo(addCharacterButton.snp.trailing).offset(5.0)
      make.trailing.equalTo(rightControlStackView.snp.leading).inset(-5.0)
      make.centerY.equalToSuperview().offset(2.0)
      make.height.equalTo(CharacterModifierControlBar.iconHeight)
    }

    rightControlStackView.snp.makeConstraints { make in
      make.trailing.equalTo(snp.trailingMargin)
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
      make.height.equalTo(CharacterModifierControlBar.height)
    }

    rightControlStackView.arrangedSubviews.forEach { view in
      view.snp.makeConstraints { make in
        make.width.equalTo(24.0)
      }
    }
    
    addBorder(.top, viewModel: FableBorderViewModel.regular)
  }

  private func configureReactive() {
  }

  private func configureReactiveDataModel() {
//    workspaceManager.onUpdate.take(duringLifetimeOf: self).observeValues { [weak self] events in
//      guard let self = self else { return }
//      for event in events {
//        switch event {
//        case let .selectCharacter(event):
//          self.selectedCharacterId = event.characterId
//        case let .characterControlBarCommand(event):
//          switch event.command {
//          case let .selectCharacter(characterId): self.selectedCharacterId = characterId
//          }
//        default:
//          break
//        }
//      }
//      self.reloadData()
//    }
  }

  public func reloadData() {
    DispatchQueue.main.async {
      self.collectionView.reloadData()
    }
  }
}

extension CharacterModifierControlBar: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//    self.workspaceManager.characters.count
    return 0
  }

  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//    let character = self.workspaceManager.characters[indexPath.row]
//    let size = character.name.sizeThatFits(
//      CharacterCollectionViewCell.estimatedSize,
//      font: .fableFont(12.0, weight: .regular)
//    )
//    return size.reverseInset(by: CharacterCollectionViewCell.contentInset)
    return .zero
  }

  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//    let character = self.workspaceManager.characters[indexPath.row]
//    let cell = collectionView.dequeueReusableCell(for: CharacterCollectionViewCell.self, at: indexPath)
//    let controlState: UIControl.State = self.selectedCharacterId == character.characterId ? .selected : .normal
//
//    // View Model
//
//    cell.configure(character: character, controlState: controlState)
//
//    return cell
    return UICollectionViewCell()
  }

  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let cell = collectionView.cellForItem(at: indexPath) as? CharacterCollectionViewCell else { return }
    guard let character = cell.character else { return }

//    let characterId = character.characterId

    if character.name.isEmpty {
      onCharacterListSelect?()
      return
    }

//    let sessionId = randomUUIDString()
//    if let selectedCharacter = self.workspaceManager.selectedCharacter, selectedCharacter.characterId == characterId {
//      self.workspaceManager.addEditEvent(.selectCharacter(.init(sessionId: sessionId, characterId: nil)))
//      if let messageId = self.workspaceManager.selectedMessage?.messageId {
//        self.workspaceManager.detachCharacterFromMessage(messageId: messageId, characterId: characterId)
//      }
//    } else {
//      self.workspaceManager.addEditEvent(.selectCharacter(.init(sessionId: sessionId, characterId: characterId)))
//      if let messageId = self.workspaceManager.selectedMessage?.messageId {
//        self.workspaceManager.attachCharacterToMessage(messageId: messageId, characterId: characterId)
//      }
//    }
//
//    self.workspaceManager.commitEditEvents(sessionId: sessionId)
  }
}
