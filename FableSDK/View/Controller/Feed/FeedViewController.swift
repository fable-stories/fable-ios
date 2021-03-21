//
//  FeedViewController.swift
//  Fable
//
//  Created by Andrew Aquino on 4/13/19.
//

import AppFoundation
import AppUIFoundation
import FableSDKResolver
import FableSDKModelObjects
import FableSDKResourceManagers
import FableSDKEnums
import FableSDKResourceTargets
import FableSDKModelManagers
import FableSDKViewPresenters
import FableSDKWireObjects
import NetworkFoundation
import FableSDKViews
import Firebolt
import Kingfisher
import ReactiveCocoa
import ReactiveFoundation
import ReactiveSwift
import SnapKit
import UIKit

public class FeedViewController: UIViewController {
  public struct FeaturedSection {
    public struct Row {}

    public let stories: [Story]

    public init(stories: [Story]) {
      self.stories = stories
    }
  }

  public struct Section {
    public struct Row {}

    public let category: Kategory
    public let stories: [Story]

    public init?(category: Kategory = Kategory(categoryId: 0, title: "All Stories"), stories: [Story]) {
      self.category = category
      self.stories = stories
      if self.stories.isEmpty {
        return nil
      }
    }

    public init(stories: [Story]) {
      self.category = Kategory(categoryId: 0, title: "All Stories")
      self.stories = stories
    }
  }

  private var feed: Feed?
  private var featuredStories: [Story] = []
  private var sections: [Section] = []

  private let resolver: FBSDKResolver
  private let configManager: ConfigManager
  private let networkManager: NetworkManagerV2
  private let stateManager: StateManager
  private let resourceManager: ResourceManager
  private let dataStoreManager: DataStoreManager
  private let imageManager: ImageManager
  private let analyticsManager: AnalyticsManager
  private let eventManager: EventManager

  public init(
    resolver: FBSDKResolver
  ) {
    self.resolver = resolver
    self.configManager = resolver.get()
    self.networkManager = resolver.get()
    self.stateManager = resolver.get()
    self.resourceManager = resolver.get()
    self.dataStoreManager = resolver.get()
    self.imageManager = resolver.get()
    self.analyticsManager = resolver.get()
    self.eventManager = resolver.get()
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  private let searchController = UISearchController(searchResultsController: nil)
  private lazy var searchBar = searchController.searchBar
  
  private lazy var refreshControl: UIRefreshControl = {
    let view = UIRefreshControl()
    view.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    return view
  }()

  private let carouselView = CarouselView(
    itemSize: CGSize(width: ScreenSize.width - 32.0, height: 190.0),
    itemSpacing: 16.0,
    isInfinite: true
  )

  private lazy var tableView = UITableView(frame: .zero, style: .grouped).also {
    $0.delegate = self
    $0.dataSource = self
    $0.register(StoryCollectionTableViewCell.self, forCellReuseIdentifier: StoryCollectionTableViewCell.reuseIdentifier)
    $0.refreshControl = refreshControl
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
    configureSelf()
    configureSubviews()
    configureLayout()
    
    refreshData()
  }

  override public func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }

  private func configureSelf() {
    navigationItem.title = "FABLE"
    view.backgroundColor = .fableWhite

    tableView.separatorColor = .clear
    tableView.sectionHeaderHeight = UITableView.automaticDimension
    tableView.estimatedSectionHeaderHeight = 70.0
    tableView.sectionFooterHeight = 0.0
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = StoryContainerView.size.height
    tableView.backgroundColor = .clear
    tableView.showsVerticalScrollIndicator = false
    tableView.contentInset = UIEdgeInsets(top: 16.0, left: 0.0, bottom: 0.0, right: 0.0)
  }

  private func configureSubviews() {
    carouselView.delegate = self
  }

  private func configureSearchBar() {
    definesPresentationContext = false

    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.hidesNavigationBarDuringPresentation = false

    searchBar.barTintColor = .fableDarkGray
    searchBar.backgroundColor = .white
    searchBar.tintColor = .fableDarkGray
    searchBar.placeholder = "Search"
    searchBar.searchBarStyle = .default
    let searchBarTextField = searchBar.value(forKey: "searchField") as? UITextField
    searchBarTextField?.backgroundColor = .fableInputField
    navigationItem.titleView = searchBar
  }

  private func configureLayout() {
    tableView.contentInset = .zero
    view.addSubview(tableView)

    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  private func configureReactive() {
    self.eventManager.onEvent.sinkDisposed(receiveCompletion: nil) { [weak self] (event) in
      switch event {
      case UserToStoryManagerEvent.didReportStory,
           UserToStoryManagerEvent.didSetStoryHidden,
           UserToStoryManagerEvent.didSetStoryLike:
        self?.refreshData()
      default:
        break
      }
    }
  }

  private func refreshData() {
    networkManager.request(
      path: "/mobile/feed",
      method: .get,
      expect: WireCollection<WireKategory>.self
    ).sinkDisposed(receiveCompletion: nil) { [weak self] wire in
      guard let self = self else { return }
      let categories = wire.items.compactMap { Kategory(wire: $0) } 
      self.feed = Feed(
        categories: categories,
        stories: categories.reduce([:]) { acc, i in
          acc.merging(i.stories.indexed(by: \.storyId), uniquingKeysWith: { $1 })
        }
      )
      self.refreshControl.endRefreshing()
      self.update()
    }
  }

  private func update() {
    guard let feed = feed else { return }
    if feed.categories.isEmpty {
      sections = [Section(stories: Array(feed.stories.values))]
    } else {
      sections = feed.categories.sorted(by: { $0.title < $1.title }).compactMap { category in
        Section(category: category, stories: category.stories)
      }
    }
    tableView.reloadData()
  }
  
  @objc private func didPullToRefresh() {
    self.refreshData()
  }
  
  private func presentStory(storyId: Int) {
    self.eventManager.sendEvent(RouterRequestEvent.present(.storyDetail(storyId: storyId), viewController: self))
  }

  private func presentStory(model: DataStore) {
    guard let vc = RKChapterViewController(resolver: resolver, model: model) else { return }
    let navVC = UINavigationController(rootViewController: vc)
    navVC.modalPresentationStyle = .fullScreen
    vc.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "closeButton")) { [weak self, weak vc] in
      if let vc = vc {
        self?.analyticsManager.trackEvent(AnalyticsEvent.didDismissReader, properties: [
          "story_id": model.story.storyId,
          "chapter_id": model.selectedChapterId,
          "message_id": vc.currentMessageId
        ])
      }
      self?.dismiss(animated: true, completion: nil)
    }
    present(navVC, animated: true, completion: nil)
  }
}

extension FeedViewController: UISearchResultsUpdating {
  public func updateSearchResults(for searchController: UISearchController) {
  }
}

extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
  public func numberOfSections(in tableView: UITableView) -> Int {
    sections.count
  }

  public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    UITableView.automaticDimension
  }

  public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
    StorySectionViewHeader.estimatedHeight
  }

  public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let section = sections[section]
    return StorySectionViewHeader(title: section.category.title, subtitle: section.category.subtitle)
  }

  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: StoryCollectionTableViewCell = tableView.dequeueReusableCell(at: indexPath)
    cell.delegate = self
    let stories = sections[indexPath.section].stories
    cell.stories = stories
    cell.onStorySelect = { [weak self] story in
      self?.analyticsManager.trackEvent(AnalyticsEvent.didSelectStoryInFeed, properties: ["story_id": story.storyId])
      self?.presentStory(storyId: story.storyId)
    }
    return cell
  }
}

extension FeedViewController: CaraouselViewDelegate {
  public func carouselView(_ carouselView: CarouselView, numberOfItemsIn collectionView: UICollectionView) -> Int {
    featuredStories.count
  }

  public func carouselView(_ carouselView: CarouselView, collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
    nil
  }
}

extension FeedViewController: StoryCollectionTableViewCellDelegate {
  public func storyCollectionTableViewCell(prefetchImageForKey key: String, view: StoryCollectionTableViewCell) -> UIImage? {
    self.imageManager.fetchImage(forKey: key)
  }
  
  public func storyCollectionTableViewCell(didRetrieveImage image: UIImage, forKey key: String, view: StoryCollectionTableViewCell) {
    self.imageManager.storeImage(image, forKey: key)
  }
}

public class FeatureCollectionViewCell: UICollectionViewCell {
  public static let size = CGSize(width: ScreenSize.width, height: 210.0)

  override public init(frame: CGRect) {
    super.init(frame: frame)
    configureSelf()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  private func configureSelf() {
    layer.cornerRadius = 8.0
    layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
    layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
    layer.shadowRadius = 6.0
    layer.shadowOpacity = 1.0
  }
}
