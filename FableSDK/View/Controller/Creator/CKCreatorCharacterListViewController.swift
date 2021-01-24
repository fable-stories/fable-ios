//
//  CharacterListViewController.swift
//  Fable
//
//  Created by Andrew Aquino on 9/12/19.
//

import AppFoundation
import AppUIFoundation
import FableSDKResolver
import FableSDKEnums
import FableSDKModelObjects
import FableSDKUIFoundation
import FableSDKModelPresenters
import FableSDKViewPresenters
import FableSDKModelManagers
import FableSDKViews
import Foundation
import ReactiveCocoa
import ReactiveSwift
import SnapKit
import UIKit

public class CharacterListViewController: UIViewController {
  private let mutableSelectedCharacterId = MutableProperty<Int?>(nil)
  private let mutableSelectedColorHexString = MutableProperty<String?>(nil)

  private let mutableLastFirstResponder = MutableProperty<UIResponder?>(nil)

  private let resolver: FBSDKResolver
  private let eventManager: EventManager
  private let characterManager: CharacterManager
  
  private let storyDraftModelPresenter: StoryDraftModelPresenter
  
  private var characters: [Character] {
    self.storyDraftModelPresenter.fetchModel()?.fetchCharacters() ?? []
  }

  public init(resolver: FBSDKResolver, storyDraftModelPresenter: StoryDraftModelPresenter) {
    self.resolver = resolver
    self.characterManager = resolver.get()
    self.eventManager = resolver.get()
    self.storyDraftModelPresenter = storyDraftModelPresenter
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder: NSCoder) {
    fatalError()
  }

  deinit {
    print("\(self) deinit")
  }

  private let tableView = UITableView().also {
    $0.register(CharacterTableViewCell.self, forCellReuseIdentifier: CharacterTableViewCell.reuseIdentifier)
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
    configureSelf()
    configureTableView()
    configureLayout()
    configureReactiveDataModel()
    
    self.storyDraftModelPresenter.reloadCharacters()
  }

  override public func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }

  override public func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }

  private func configureSelf() {
    view.backgroundColor = .white

    navigationItem.title = "Character List"

    navigationItem.rightBarButtonItem = .makeAddButton(onSelect: { [weak self] in
      self?.appendNewCharacter()
    })
  }

  private func configureTableView() {
    tableView.dataSource = self
    tableView.delegate = self
    tableView.separatorColor = .clear
    tableView.backgroundColor = .clear
    tableView.estimatedRowHeight = CharacterTableViewCell.height
    tableView.rowHeight = UITableView.automaticDimension
  }

  private func configureLayout() {
    view.addSubview(tableView)

    tableView.snp.makeConstraints { make in
      make.edges.equalTo(view.snp.edges)
    }
  }

  private func configureReactiveDataModel() {
    mutableSelectedColorHexString.signal.take(duringLifetimeOf: self).observeValues { [weak self] hexString in
      guard let self = self else { return }
      guard let characterId = self.mutableSelectedCharacterId.value else { return }
      self.storyDraftModelPresenter.updateCharacter(
        characterId,
        name: nil,
        colorHexString: hexString,
        messageAlignment: nil
      )
      self.reloadData()
    }
    
    self.eventManager.onEvent.sinkDisposed(receiveCompletion: nil) { [weak self] event in
      switch event {
      case StoryDraftModelPresenterEvent.didRefreshCharacters:
        self?.reloadData()
      default:
        break
      }
    }
  }

  private func appendNewCharacter() {
    guard let model = self.storyDraftModelPresenter.fetchModel() else { return }
    let messageAlignment: MessageAlignment = self.characters.count == 1 ? .trailing : .leading
    self.characterManager.insert(
      storyId: model.fetchStory().storyId,
      name: "",
      colorHexString: model.colorHexString.randomElement() ?? "",
      messageAlignment: messageAlignment.rawValue
    ).sinkDisposed(receiveCompletion: nil) { [weak self] character in
      guard let character = character else { return }
      self?.storyDraftModelPresenter.insertCharacter(character)
      self?.reloadData()
    }
  }

  private func reloadData() {
    DispatchQueue.main.async {
      self.tableView.reloadData()
    }
  }
}

extension CharacterListViewController: UITableViewDelegate, UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    self.characters.count
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: CharacterTableViewCell = tableView.dequeueReusableCell(at: indexPath)
    let character = self.characters[indexPath.row]

    // Data Model

    cell.character = character

    // Reactive

    // Interactions

    cell.colorButton.reactive.pressed = .invoke { [weak self] in
      guard let self = self else { return }
      self.colorPickerPressed(characterId: character.characterId)
    }

    cell.alignmentButton.reactive.pressed = .invoke { [weak self] in
      self?.mutableLastFirstResponder.value?.resignFirstResponder()
      let alert = UIAlertController(title: "Character Message Alignment", message: nil, preferredStyle: .actionSheet)
      alert.addAction(UIAlertAction(title: "Left", style: .default, handler: { [weak self] _ in
        guard let self = self else { return }
        self.storyDraftModelPresenter.updateCharacter(
          character.characterId,
          name: nil,
          colorHexString: nil,
          messageAlignment: .leading
        )
        self.reloadData()
      }))
      alert.addAction(UIAlertAction(title: "Center", style: .default, handler: { [weak self] _ in
        guard let self = self else { return }
        self.storyDraftModelPresenter.updateCharacter(
          character.characterId,
          name: nil,
          colorHexString: nil,
          messageAlignment: .center
        )
        self.reloadData()
      }))
      alert.addAction(UIAlertAction(title: "Right", style: .default, handler: { [weak self] _ in
        guard let self = self else { return }
        self.storyDraftModelPresenter.updateCharacter(
          character.characterId,
          name: nil,
          colorHexString: nil,
          messageAlignment: .trailing
        )
        self.reloadData()
      }))
      alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
      self?.present(alert, animated: true, completion: nil)
    }

    // Delegates
    cell.textField.delegate = cell
    cell.onBeginEdit = { [weak self] textField in
      guard let self = self else { return }
      
      if textField != self.mutableLastFirstResponder.value {
        self.mutableLastFirstResponder.value?.resignFirstResponder()
      }
      self.mutableLastFirstResponder.value = textField
    }

    cell.onEndEdit = { [weak self] textField in
      guard let text = textField.text, let self = self else { return }
      self.storyDraftModelPresenter.updateCharacter(
        character.characterId,
        name: text,
        colorHexString: nil,
        messageAlignment: nil
      )
    }

    cell.onKeyReturn = { [weak self] textField in
      guard let self = self else { return }
      self.mutableLastFirstResponder.value?.resignFirstResponder()
    }
    
    return cell
  }

  public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {}

  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}

  public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    true
  }

  public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let character = self.characters[indexPath.row]
    let delete = UIContextualAction(
      style: .destructive,
      title: "Delete", handler: { [weak self] _, _, complete in
        guard let self = self else { return complete(false) }
        self.storyDraftModelPresenter.removeCharacter(character.characterId)
        self.reloadData()
        complete(true)
      }
    )
    delete.image = UIImage(named: "trashIcon")
    delete.backgroundColor = .fableWhite
    return UISwipeActionsConfiguration(actions: [delete])
  }

  private func colorPickerPressed(characterId: Int) {
    guard let model = self.storyDraftModelPresenter.fetchModel() else { return }
    let vc = ColorPickerViewController(
      colorHexStrings: model.colorHexString,
      mutableSelectedColorHexString: mutableSelectedColorHexString
    )
    vc.navigationItem.leftBarButtonItem = .makeBackButton(onSelect: { [weak self] in
      self?.navigationController?.popViewController(animated: true)
    })
    navigationController?.pushViewController(vc, animated: true)

    guard let character = model.fetchCharacter(characterId: characterId) else { return }
    mutableLastFirstResponder.value?.resignFirstResponder()
    // new selection
    mutableSelectedCharacterId.value = characterId
    mutableSelectedColorHexString.value = character.colorHexString
  }
}

extension CharacterTableViewCell: UITextFieldDelegate {
  public func textFieldDidBeginEditing(_ textField: UITextField) {
    self.onBeginEdit?(textField)
  }

  public func textFieldDidEndEditing(_ textField: UITextField) {
    self.onEndEdit?(textField)
  }

  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.onKeyReturn?(textField)
    return true
  }
}

public class CharacterTableViewCell: UITableViewCell {
  public static let height: CGFloat = 52.0

  public var onEndEdit: ((UITextField) -> Void)?
  public var onBeginEdit: ((UITextField) -> Void)?
  public var onKeyReturn: ((UITextField) -> Void)?
  
  public let textField = UITextField.create {
    $0.font = .fableFont(16.0, weight: .light)
    $0.autocorrectionType = .no
    $0.autocapitalizationType = .words
    $0.returnKeyType = .done
    $0.placeholder = "Character Name"
  }

  private let rightControlStackView = UIStackView.create {
    $0.axis = .horizontal
    $0.distribution = .fillProportionally
    $0.alignment = .trailing
    $0.spacing = 16.0
  }

  public let alignmentButton = UIButton.create {
    $0.setImage(UIImage(named: "alignmentIcon"), for: .normal)
  }

  public let colorButton = UIButton.create {
    $0.layer.cornerRadius = 4.0
    $0.layer.borderWidth = 1.0
  }

  public var character: Character? {
    didSet {
      update()
    }
  }

  override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    configureSelf()
    configureLayout()
    configureReactive()
  }

  public required init?(coder: NSCoder) {
    fatalError()
  }

  private func configureSelf() {
    selectionStyle = .none
    addBorder(.bottom, viewModel: FableBorderViewModel.regular)
  }

  private func configureLayout() {
    layoutMargins = .zero
    contentView.layoutMargins = UIEdgeInsets(top: 0.0, left: 24.0, bottom: 0.0, right: 20.0)

    contentView.addSubview(textField)
    contentView.addSubview(rightControlStackView)
    rightControlStackView.addArrangedSubview(alignmentButton)
    rightControlStackView.addArrangedSubview(colorButton)

    textField.snp.makeConstraints { make in
      make.leading.equalTo(contentView.snp.leading).inset(contentView.layoutMargins.left)
      make.trailing.equalTo(colorButton.snp.leading).offset(-20.0)
      make.top.equalTo(contentView.snp.top)
      make.bottom.equalTo(contentView.snp.bottom)
      make.height.greaterThanOrEqualTo(CharacterTableViewCell.height)
    }

    rightControlStackView.snp.makeConstraints { make in
      make.trailing.equalTo(contentView.snp.trailingMargin)
      make.centerY.equalTo(contentView.snp.centerY)
    }

    colorButton.snp.makeConstraints { make in
      make.width.equalTo(18.0)
      make.height.equalTo(18.0)
    }

    alignmentButton.snp.makeConstraints { make in
      make.width.equalTo(18.0)
      make.height.equalTo(18.0)
    }
  }

  private func configureReactive() {
    textField.reactive.continuousTextValues
      .take(duringLifetimeOf: self)
      .observeValues { [weak self] text in
        self?.character = self?.character?.copy(name: text)
      }
  }

  private func update() {
    guard let character = self.character else { return }

    textField.text = character.name
    colorButton.backgroundColor = character.color
    switch (character.messageAlignment) {
      case .leading:
        alignmentButton.setImage(UIImage(named: "align-left"), for: .normal)
      case .center:
        alignmentButton.setImage(UIImage(named: "align-center"), for: .normal)
      case .trailing:
        alignmentButton.setImage(UIImage(named: "align-right"), for: .normal)
    }
  }

  override public func becomeFirstResponder() -> Bool {
    textField.becomeFirstResponder()
  }

  @discardableResult
  override public func resignFirstResponder() -> Bool {
    textField.resignFirstResponder()
  }

  override public func prepareForReuse() {
    super.prepareForReuse()
    character = nil
    textField.text = nil
    colorButton.backgroundColor = .white
  }
}
