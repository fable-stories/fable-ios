//
//  CarouselView.swift
//  Fable
//
//  Created by Andrew Aquino on 4/13/19.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa
import SnapKit

public protocol CaraouselViewDelegate: class {
  func carouselView(_ carouselView: CarouselView, numberOfItemsIn collectionView: UICollectionView) -> Int
  func carouselView(_ carouselView: CarouselView, collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell?
  func carouselView(_ carouselView: CarouselView, collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
  func carouselView(_ carouselView: CarouselView, collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
}

extension CaraouselViewDelegate {
  public func carouselView(_ carouselView: CarouselView, collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}
  public func carouselView(_ carouselView: CarouselView, collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {}
}

public class CarouselView: UIView {
  private let itemSize: CGSize
  private let itemSpacing: CGFloat
  
  private var panStartLocation: CGPoint = .zero

  private let panGesture = UIPanGestureRecognizer()
  private var currentSwipeDistance: CGFloat = 0.0

  private var currentIndex: Int = 0
  private var isResettingIndex: Bool = false
  private var (didScrollSignal, didScrollObserver) = Signal<(), Never>.pipe()
  
  private let isInfinite: Bool
  private var viewDidLoad: Bool = false
  
  public weak var delegate: CaraouselViewDelegate?

  private func itemCount() -> Int {
    return delegate?.carouselView(self, numberOfItemsIn: collectionView) ?? 0
  }
  
  private var resetIndex: Int {
    return itemCount() * 3 / 2
  }
  
  private var lTrigger: Int {
    return itemCount() / 2
  }
  
  private var rTrigger: Int {
    return itemCount() * 5 / 2
  }

  public init(
    itemSize: CGSize,
    itemSpacing: CGFloat,
    isInfinite: Bool
  ) {
    self.itemSize = itemSize
    self.itemSpacing = itemSpacing
    self.isInfinite = isInfinite
    super.init(frame: .zero)
    configureSelf()
    configureLayout()
    configureGestures()
    configureReactive()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError()
  }
  
  private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.itemSize = itemSize
    layout.minimumInteritemSpacing = 0.0
    return layout
  }()
  
  private lazy var collectionView: UICollectionView = {
    let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    view.isPagingEnabled = false
    view.delegate = self
    view.dataSource = self
    view.clipsToBounds = false
    view.showsHorizontalScrollIndicator = false
    return view
  }()

  private func configureSelf() {
    backgroundColor = .clear
    collectionView.backgroundColor = .clear
    collectionView.register(TestCell.self, forCellWithReuseIdentifier: TestCell.reuseIdentifier)
  }
  
  private func configureLayout() {
    let edgeInsets = UIEdgeInsets(top: 0.0, left: itemSpacing, bottom: 0.0, right: itemSpacing)
    collectionView.contentInset = edgeInsets
    
    addSubview(collectionView)
    
    collectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func configureGestures() {
    panGesture.addTarget(self, action: #selector(didPan(gesture:)))
    panGesture.delegate = self
    addGestureRecognizer(panGesture)
  }
  
  private func configureReactive() {
    didScrollSignal.debounce(0.03, on: QueueScheduler.main).take(duringLifetimeOf: self).observeValues { [weak self] in
      guard let self = self else { return }
      if self.isInfinite {
        self.scrollToResetableIndex()
      }
    }
  }

  public override func layoutSubviews() {
    super.layoutSubviews()
    if isInfinite, !viewDidLoad {
      viewDidLoad = true
      scrollToItem(at: resetIndex, animated: false, completion: nil)
    }
  }
  
  public func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier: String) {
    collectionView.register(cellClass, forCellWithReuseIdentifier: forCellWithReuseIdentifier)
  }
  
  public func reloadData() {
    collectionView.reloadData()
  }
}

extension CarouselView: UICollectionViewDelegate, UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return itemCount() * (isInfinite ? 3 : 1)
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let index = indexPath.row % itemCount()
    let _cell = delegate?.carouselView(self, collectionView: collectionView, cellForItemAt: IndexPath(item: index, section: indexPath.section))
    guard let cell = _cell else {
      let cell = collectionView.dequeueReusableCell(for: TestCell.self, at: indexPath)
      cell.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
      cell.layer.cornerRadius = 8.0
      return cell
    }
   return cell
  }
  
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    delegate?.carouselView(self, collectionView: collectionView, didSelectItemAt: indexPath)
  }
  
  public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    delegate?.carouselView(self, collectionView: collectionView, didDeselectItemAt: indexPath)
  }

  private func indexPathClosest(to x: CGFloat) -> IndexPath? {
    let point = convert(
      CGPoint(x: min(max(x, 0.0), collectionView.bounds.width),
              y: collectionView.center.y),
      to: collectionView
    )
    guard let cell = collectionView.visibleCells.first(where: { $0.frame.contains(point) }) else { return nil }
    return collectionView.indexPath(for: cell)
  }
}

extension CarouselView: UICollectionViewDelegateFlowLayout {
  public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
    scrollToItemMostRelativeToSwipe()
  }

  public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    collectionView.isUserInteractionEnabled = isInfinite ? !isResettingIndex : true
    scrollToItemMostRelativeToSwipe()
  }
  
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    didScrollObserver.send(value: ())
  }
  
  @discardableResult
  private func scrollToResetableIndex() -> Bool {
    guard isInfinite else { return false }
    if isResettingIndex { return true }
    switch currentIndex {
    case _ where currentIndex <= lTrigger: return scrollToResettingIndex(resetIndex)
    case _ where currentIndex >= rTrigger: return scrollToResettingIndex(resetIndex)
    default: return false
    }
  }
  
  private func scrollToResettingIndex(_ index: Int) -> Bool {
    isResettingIndex = true
    scrollToItem(at: index, animated: false) { [weak self] in
      self?.isResettingIndex = false
    }
    return true
  }
  
  private func scrollToItemMostRelativeToSwipe() {
    guard isInfinite else { return }
    let x = collectionView.center.x - currentSwipeDistance
    let indexPath = indexPathClosest(to: x)
    scrollToItem(at: indexPath?.row, animated: true, completion: nil)
  }

  private func scrollToItem(at index: Int?, animated: Bool, completion: (()-> Void)?) {
    guard let index = index, itemCount() > 0 else { completion?(); return }
    CATransaction.begin()
    CATransaction.setCompletionBlock {
      self.currentIndex = index
      completion?()
    }
    collectionView.scrollToItem(
      at: IndexPath(item: index, section: 0),
      at: .centeredHorizontally,
      animated: animated
    )
    CATransaction.commit()
  }
}

extension CarouselView: UIGestureRecognizerDelegate {
  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
  @objc func didPan(gesture: UIPanGestureRecognizer) {
    switch gesture.state {
    case .began: panStartLocation = gesture.location(in: self)
    case .changed: currentSwipeDistance = (panGesture.location(in: self).x - panStartLocation.x) * 2.0
    default: break
    }
  }
}

extension CarouselView {
  fileprivate class TestCell: UICollectionViewCell {}
}
