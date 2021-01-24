//
//  ChapterViewController.swift
//  Fable
//
//  Created by Andrew Aquino on 12/22/19.
//

import AppFoundation
import AppUIFoundation
import FableSDKEnums
import FableSDKResolver
import FableSDKModelObjects
import FableSDKResourceTargets
import FableSDKViewPresenters
import FableSDKUIFoundation
import FableSDKEnums
import FableSDKModelManagers
import ReactiveSwift
import ReactiveCocoa
import UIKit

public class RKChapterViewController: UIViewController {
  private var currentSectionIndex: Int = -1
  private var visibleSections: [Section] = []
  private var sections: [Section] = []

  private let resolver: FBSDKResolver
  private let analyticsManager: AnalyticsManager
  private let storyStatsManager: StoryStatsManager
  private let presenter: RKPresenter

  private var didAppearOnce: Bool = false
  
  public private(set) var currentMessageId: Int = -1
  
  /// Analytics
  
  private var didTrackedStoryCompletion: Bool = false
  private var storyStartedAt: Date = .now
  private var previousMessageSeenAt: Date = .now

  public init?(
    resolver: FBSDKResolver,
    model: DataStore
  ) {
    guard let presenter = RKPresenter(resolver: resolver, model: model) else {
      return nil
    }
    self.resolver = resolver
    self.analyticsManager = resolver.get()
    self.storyStatsManager = resolver.get()
    self.presenter = presenter
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder: NSCoder) {
    fatalError()
  }
  
  // MARK: Subviews

  private lazy var tableView = UITableView(frame: .zero, style: .grouped).also {
    $0.dataSource = self
    $0.delegate = self
    $0.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.reuseIdentifier)
    $0.register(MessageTableViewCell.self, forCellReuseIdentifier: MessageTableViewCell.reuseIdentifier)
    $0.register(TailTableViewCell.self, forCellReuseIdentifier: TailTableViewCell.reuseIdentifier)
  }
  private let instructionsContainer = UIView()
  private let instructionsButton = Button(FableButtonViewModel.plain())

  // MARK: View Life Cycles

  override public func viewDidLoad() {
    super.viewDidLoad()
    configureSelf()
    configureLayout()
    reloadData()
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if !didAppearOnce {
      didAppearOnce = true
      self.storyStatsManager.incrementViews(storyId: presenter.story.storyId).sinkDisposed()
    }
  }

  private func configureSelf() {
    navigationItem.title = presenter.story.title

    view.backgroundColor = .white
    edgesForExtendedLayout = []

    tableView.separatorColor = .clear
    tableView.backgroundColor = .white
    tableView.sectionHeaderHeight = 0.0
    tableView.sectionFooterHeight = 0.0
    tableView.contentInset = UIEdgeInsets(
      top: 20.0,
      left: 0.0,
      bottom: 36.0,
      right: 0.0
    )
    tableView.tableHeaderView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: CGFloat.leastNonzeroMagnitude, height: CGFloat.leastNonzeroMagnitude)))
    tableView.estimatedRowHeight = MessageTableViewCell.estimatedHeight
    tableView.rowHeight = UITableView.automaticDimension
    tableView.showsVerticalScrollIndicator = false

    instructionsButton.title = "Tap to start reading."
    instructionsContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(instructionsButtonClicked)))

    tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tableViewTapped)))

    navigationController?.hidesBarsOnSwipe = true

    presenter.onUpdate.take(duringLifetimeOf: self).compactMap { [weak self] _ in
      self?.presenter.messages.first
    }.take(first: 1).observeValues { [weak self] _ in
      self?.reloadData()
    }

    presenter.onUpdate.take(duringLifetimeOf: self).observeValues { [weak self] in
      self?.reloadData()
    }
  }

  private func configureLayout() {
    view.addSubview(tableView)
    tableView.addSubview(instructionsContainer)
    instructionsContainer.addSubview(instructionsButton)

    instructionsContainer.snp.makeConstraints { make in
      make.edges.equalTo(view.snp.edges)
    }
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(view.snp.edges)
    }
    instructionsButton.snp.makeConstraints { make in
      make.width.equalToSuperview()
      make.center.equalTo(instructionsContainer.snp.center)
    }
  }

  override public var prefersStatusBarHidden: Bool {
    true
  }

  // MARK: View Interaction

  @objc private func tableViewTapped() {
    nextMessage()
  }

  @objc private func instructionsButtonClicked() {
    UIView.animate (withDuration: 1, delay: 0.3, animations: { [weak self] in
      self?.instructionsContainer.removeFromSuperview()
      self?.nextMessage()
    })
  }

  private func nextMessage() {
    if currentSectionIndex + 1 >= sections.count || sections.isEmpty { return }

    if let navigationController = navigationController, !navigationController.isNavigationBarHidden {
      DispatchQueue.main.async {
        navigationController.setNavigationBarHidden(true, animated: true)
      }
    }
    
    let sectionIndex = currentSectionIndex + 1
    let section = sections[sectionIndex]
    
    /// -- Analytics --

    /// User tapped to see first message, begin start time
    if self.currentMessageId == Section.SpecialSection.none.rawValue {
      self.storyStartedAt = .now
    }
    
    self.analyticsManager.trackEvent(AnalyticsEvent.didTapNextMessageInReader, properties: [
      "story_id": presenter.story.storyId,
      "chapter_id": presenter.currentChapterId,
      "message_id": section.messageId,
      "previous_message_id": self.currentMessageId,
      "previous_message_view_time": self.previousMessageSeenAt.millisecondsFromNow()
    ])
    
    self.currentMessageId = section.messageId
    self.previousMessageSeenAt = .now
    
    if currentSectionIndex >= self.presenter.messages.count - 1, !didTrackedStoryCompletion {
      self.didTrackedStoryCompletion = true
      self.markStoryAsCompleted()
    }
    
    /// -- End Analyticcs --
    

    visibleSections.append(section)

    let index = IndexSet(integer: sectionIndex)

    self.tableView.insertSections(index, with: .none)

    let indexPath = IndexPath(row: max(section.rows.count - 1, 0), section: sectionIndex)

    DispatchQueue.main.async {
      if self.tableView.visibleCells.count > 0 {
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
      }
    }

    currentSectionIndex = sectionIndex
  }
  
  private func markStoryAsCompleted() {
    self.analyticsManager.trackEvent(AnalyticsEvent.didCompleteStoryInReader, properties: [
      "story_id": presenter.story.storyId,
      "chapter_id": presenter.currentChapterId,
      "message_id": currentMessageId,
      "previous_message_id": self.currentMessageId,
      "previous_message_view_time": self.previousMessageSeenAt.millisecondsFromNow(),
      "story_readership_time": self.storyStartedAt.millisecondsFromNow()
    ])
  }

  // MARK: Data Model

  private func reloadData() {
    let messages = presenter.messages
    sections = messages.enumerated().map { index, message in
      let prevIndex = index - 1
      let prevMessage: Message? = {
        if prevIndex >= 0 {
          return messages[prevIndex]
        }
        return nil
      }()
      return  Section(message, previousMessage: prevMessage)
    }
    let tailMessage = presenter.story.title
    let tailSection = Section(tailMessage)
    sections.append(tailSection)
  }

  private func resetState() {
    navigationController?.setNavigationBarHidden(false, animated: true)

    visibleSections = []
    currentSectionIndex = -1
    tableView.reloadData()
  }
}

extension RKChapterViewController: UITableViewDataSource, UITableViewDelegate {
  public func numberOfSections(in tableView: UITableView) -> Int {
    visibleSections.count
  }

  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let section = visibleSections[section]
    let count = section.rows.count
    return count
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let section = visibleSections[indexPath.section]
    let row = section.rows[indexPath.row]
    switch row {
    case let .narrative(title, color):
      let cell: TitleTableViewCell = tableView.dequeueReusableCell(at: indexPath)
      cell.setCellKind(.narrative)
      cell.attributedTitle = title.title13(color, alignment: section.alignment.textAlignment)
      return cell
    case let .character(title, color):
      let cell: TitleTableViewCell = tableView.dequeueReusableCell(at: indexPath)
      cell.setCellKind(.character)
      cell.attributedTitle = title.title13(color, alignment: section.alignment.textAlignment)
      return cell
    case let .message(text, color):
      let cell: MessageTableViewCell = tableView.dequeueReusableCell(at: indexPath)
      cell.attributedMessage = text.body16(.fableWhite, alignment: section.alignment.textAlignment)
      cell.messageBackgroundColor = color
      cell.alignment = section.alignment
      return cell
    case let .tail(text):
      let cell: TailTableViewCell = tableView.dequeueReusableCell(at: indexPath)
      cell.dismissCallback = { [weak self] in
        guard let self = self else { return }
        self.analyticsManager.trackEvent(AnalyticsEvent.didDismissReader, properties: [
          "story_id": self.presenter.story.storyId,
          "chapter_id": self.presenter.currentChapterId,
          "message_id": self.currentMessageId
        ])
        self.dismiss(animated: true, completion: nil)
      }
      cell.attributedTailLabel = text
      return cell
    }
  }

  public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    switch cell {
    case let cell as TitleTableViewCell:
      if cell.didAnimateIn { return }
      cell.animateIn()
    case let cell as MessageTableViewCell:
      if cell.didAnimateIn { return }
      cell.animateIn()
    case let cell as TailTableViewCell:
      if cell.didAnimateIn { return }
      cell.animateIn()
    default:
      break
    }
  }
}

extension RKChapterViewController {
  public struct Section {
    public enum SpecialSection: Int {
      case none = -1
      case tail = -2
    }
    
    public enum Row {
      case narrative(String, UIColor)
      case character(String, UIColor)
      case message(String, UIColor)
      case tail(String)
    }
    
    public let messageId: Int

    public let alignment: MessageAlignment
    public let rows: [Row]

    public init(_ tailMessage: String) {
      self.messageId = SpecialSection.tail.rawValue
      var rows: [Row] = []
      // tail message
      rows.append(.tail(tailMessage))
      self.alignment = .center
      self.rows = rows
    }

    public init(_ message: Message, previousMessage: Message?) {
      self.messageId = message.messageId
      var rows: [Row] = []
      // character message
      if let character = message.character {
        if let prevCharacter = previousMessage?.character, prevCharacter.characterId == character.characterId {
          // don't add a character name
        } else {
          rows.append(.character(character.name, character.color ?? .fableDarkGray))
        }
        rows.append(.message(message.text, character.color ?? .fableDarkGray))
        self.alignment = character.messageAlignment
      } else {
        // narrative message
        rows.append(.narrative(message.text, .fableDarkGray))
        self.alignment = .center
      }
      self.rows = rows
    }
  }
}

private protocol AnimatingTableViewCell where Self: UITableViewCell {
  var didAnimateIn: Bool { get }
  func animateIn()
}

extension RKChapterViewController {
  public class TitleTableViewCell: UITableViewCell, AnimatingTableViewCell {
    public enum CellKind {
      case character
      case narrative
    }
    
    private let titleLabel = UITextView.create {
      $0.textContainerInset = .zero
      $0.contentInset = .zero
      $0.isScrollEnabled = false
      $0.isUserInteractionEnabled = false
      $0.backgroundColor = .clear
    }

    public var attributedTitle: NSAttributedString? {
      didSet {
        titleLabel.attributedText = attributedTitle
      }
    }

    public var didAnimateIn: Bool = false

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      configureSelf()
      configureLayout()
    }

    public required init?(coder aDecoder: NSCoder) {
      fatalError()
    }

    private func configureSelf() {
      selectionStyle = .none
      backgroundColor = .clear
      isUserInteractionEnabled = false
    }

    private func configureLayout() {
      layoutMargins = .zero
      contentView.layoutMargins = .zero
      contentView.addSubview(titleLabel)
      
      titleLabel.snp.makeConstraints { make in
        make.edges.equalToSuperview().inset(contentView.layoutMargins)
      }
    }
    
    override public func updateConstraints() {
      super.updateConstraints()
    }

    public func animateIn() {
      contentView.alpha = 0.0
      UIView.animate(withDuration: 0.2, delay: 0.0, options: [], animations: {
        self.contentView.alpha = 1.0
      }, completion: { _ in
        self.didAnimateIn = true
      })
    }
    
    public func setCellKind(_ cellKind: CellKind) {
      switch cellKind {
      case .character:
        titleLabel.textContainerInset = UIEdgeInsets(top: 0.0, left: 22.0, bottom: 8.0, right: 28.0)
      case .narrative:
        titleLabel.textContainerInset = UIEdgeInsets(top: 15.0, left: 36.0, bottom: 25.0, right: 36.0)
      }
    }
    
    public override func layoutSubviews() {
      super.layoutSubviews()
    }
  }

  public class MessageTableViewCell: UITableViewCell, AnimatingTableViewCell {
    public static let estimatedHeight: CGFloat = 40.0
    private let textView = UITextView.create {
      $0.isScrollEnabled = false
      $0.layer.cornerRadius = 16.0
      $0.textContainerInset = UIEdgeInsets(top: 5.0, left: 10.0, bottom: 4.0, right: 10.0)
      $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    public var alignment: MessageAlignment = .center {
      didSet {
        updateConstraints()
      }
    }

    public var attributedMessage: NSAttributedString? {
      didSet {
        textView.attributedText = attributedMessage
      }
    }

    public var messageBackgroundColor: UIColor = .clear {
      didSet {
        textView.backgroundColor = messageBackgroundColor
      }
    }

    public var didAnimateIn: Bool = false

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      configureSelf()
      configureLayout()
    }

    public required init?(coder aDecoder: NSCoder) {
      fatalError()
    }

    private func configureSelf() {
      selectionStyle = .none
      backgroundColor = .clear
      isUserInteractionEnabled = false
    }

    private func configureLayout() {
      layoutMargins = .zero
      contentView.layoutMargins = UIEdgeInsets(top: 0.0, left: 26.0, bottom: 10.0, right: 26.0)
      contentView.addSubview(textView)

      textView.snp.makeConstraints { make in
        switch alignment {
        case .leading:
          make.trailing.lessThanOrEqualTo(contentView).offset(-36.0)
          make.leading.equalToSuperview().inset(contentView.layoutMargins)
        case .center:
          make.center.equalToSuperview()
          make.trailing.lessThanOrEqualToSuperview().inset(contentView.layoutMargins)
          make.leading.lessThanOrEqualToSuperview().inset(contentView.layoutMargins)
        case .trailing:
          make.trailing.equalToSuperview().inset(contentView.layoutMargins)
          make.leading.greaterThanOrEqualTo(contentView).offset(36.0)
        }
        make.top.equalToSuperview().inset(contentView.layoutMargins)
        make.bottom.equalToSuperview().inset(contentView.layoutMargins)
        make.height.greaterThanOrEqualTo(36.0)
      }
    }

    override public func updateConstraints() {
      textView.snp.remakeConstraints { make in
        switch alignment {
        case .leading:
          make.trailing.lessThanOrEqualTo(contentView).offset(-36.0)
          make.leading.equalToSuperview().inset(contentView.layoutMargins)
        case .center:
          make.trailing.equalToSuperview().inset(contentView.layoutMargins)
          make.leading.equalToSuperview().inset(contentView.layoutMargins)
        case .trailing:
          make.trailing.equalToSuperview().inset(contentView.layoutMargins)
          make.leading.greaterThanOrEqualTo(contentView).offset(36.0)
        }
        make.top.equalToSuperview().inset(contentView.layoutMargins)
        make.bottom.equalToSuperview().inset(contentView.layoutMargins)
        make.height.greaterThanOrEqualTo(36.0)
      }
      super.updateConstraints()
    }

    public func animateIn() {
      contentView.alpha = 0.0
      UIView.animate(withDuration: 0.3, delay: 0.2, options: [], animations: {
        self.contentView.alpha = 1.0
      }, completion: { _ in
        self.didAnimateIn = true
      })
    }
  }

  public class TailTableViewCell: UITableViewCell, AnimatingTableViewCell {
    private let padding = UIView()
    private let tailLabel = UILabel.create {
      $0.numberOfLines = 0
    }
    private let tailSubLabel = UILabel.create {
      $0.numberOfLines = 0
    }
    private let dismissButton = Button(FableButtonViewModel.primaryButton())
    public var dismissCallback: (() -> Void)? = nil

    public var attributedTailLabel: String? {
      didSet {
        tailLabel.attributedText = attributedTailLabel?
          .title16(.fableBlack, alignment: .center)
        tailSubLabel.attributedText = "End of Story"
          .title13(.fableDarkGray, alignment: .center)
      }
    }

    public var didAnimateIn: Bool = false

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      configureSelf()
      configureSubviews()
      configureLayout()
    }

    public required init?(coder aDecoder: NSCoder) {
      fatalError()
    }

    private func configureSelf() {
      selectionStyle = .none
      backgroundColor = .clear
    }

    private func configureSubviews() {
      padding.addBorder(.top, viewModel: FableBorderViewModel.regular)
      dismissButton.title = "Exit Story"
      dismissButton.addShadow(FableShadowViewModel.regular)
      dismissButton.reactive.pressed = .invoke { [weak self] in
        self?.dismissCallback?()
      }
    }

    private func configureLayout() {
      layoutMargins = .zero
      contentView.layoutMargins = UIEdgeInsets(top: 0.0, left: 36.0, bottom: 0.0, right: 36.0)
      contentView.addSubview(padding)
      contentView.addSubview(tailLabel)
      contentView.addSubview(tailSubLabel)
      contentView.addSubview(dismissButton)

      padding.snp.makeConstraints { make in
        make.leading.equalToSuperview().inset(contentView.layoutMargins)
        make.trailing.equalToSuperview().inset(contentView.layoutMargins)
        make.top.equalToSuperview().inset(contentView.layoutMargins).offset(24.0)
      }

      tailLabel.snp.makeConstraints { make in
        make.top.equalTo(padding.snp.bottom).offset(10.0)
        make.leading.equalToSuperview().inset(contentView.layoutMargins)
        make.trailing.equalToSuperview().inset(contentView.layoutMargins)
        make.height.equalTo(25.0)
      }

      tailSubLabel.snp.makeConstraints { make in
        make.top.equalTo(tailLabel.snp.bottom)
        make.leading.equalToSuperview().inset(contentView.layoutMargins)
        make.trailing.equalToSuperview().inset(contentView.layoutMargins)
        make.height.equalTo(25.0)
      }

      dismissButton.snp.makeConstraints { make in
        make.top.equalTo(tailSubLabel.snp.bottom).offset(10.0)
        make.leading.equalToSuperview().inset(contentView.layoutMargins)
        make.trailing.equalToSuperview().inset(contentView.layoutMargins)
        make.bottom.equalToSuperview().inset(contentView.layoutMargins)
        make.height.equalTo(40.0)
      }
    }

    public func animateIn() {
      contentView.alpha = 0.0
      UIView.animate(withDuration: 0.2, delay: 0.0, options: [], animations: {
        self.contentView.alpha = 1.0
      }, completion: { _ in
        self.didAnimateIn = true
      })
    }
  }

}

private extension Date {
  func millisecondsFromNow() -> Int {
    Int(abs(self.timeIntervalSince(.now)) * 1000)
  }
}
