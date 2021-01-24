//
//  ColorPickerView.swift
//  Fable
//
//  Created by Andrew Aquino on 10/4/19.
//

import AppFoundation
import FableSDKUIFoundation
import ReactiveSwift
import SnapKit
import UIKit

public class ColorPickerView: UIView {
  public static let height: CGFloat = 258.0
  public static let collectionViewHeight: CGFloat = 150.0
  public static let itemSize = CGSize(width: 40.0, height: 40.0)
  public static let itemInterimSpacing: CGFloat = 15.0
  public static let itemLineSpacing: CGFloat = 20.0

  private static func numberOfItemsInSection() -> Int {
    let contentHeight: CGFloat = 150.0
    return Int(ceil(contentHeight / (ColorPickerView.itemSize.width + CGFloat(ColorPickerView.itemInterimSpacing * 2.0))))
  }

  public struct Section {
    public struct Item {
      public let colorHexString: String
      public let selectedColorHexString: Property<String?>
    }

    public let items: [Item]
  }

  private let mutableSelectedColorHexString: MutableProperty<String?>
  private let colorHexStrings: Property<[String]>

  private let sections: Property<[Section]>

  public init(
    mutableSelectedColorHexString: MutableProperty<String?>,
    colorHexStrings: Property<[String]>
  ) {
    self.mutableSelectedColorHexString = mutableSelectedColorHexString
    self.colorHexStrings = colorHexStrings
    self.sections = colorHexStrings.map { colorHexStrings in
      let maxItemCount = ColorPickerView.numberOfItemsInSection()
      var sections: [Section] = []
      var items: [Section.Item] = []
      for (index, colorHexString) in colorHexStrings.enumerated() {
        if index % maxItemCount < maxItemCount - 1 {
          items.append(Section.Item(colorHexString: colorHexString, selectedColorHexString: mutableSelectedColorHexString.map { $0 }))
        } else {
          items.append(Section.Item(colorHexString: colorHexString, selectedColorHexString: mutableSelectedColorHexString.map { $0 }))
          sections.append(Section(items: items))
          items.removeAll()
        }
      }
      // Add the last section, if thers any items left
      if(items.count > 0) {
        sections.append(Section(items: items))
        items.removeAll()
      }

      return sections
    }

    super.init(frame: .zero)
    configureSelf()
    configureLayout()
  }

  public required init?(coder: NSCoder) {
    fatalError()
  }

  private let titleLabel = UILabel.create {
    $0.textColor = .fableBackgroundTextGray
    $0.font = .fableFont(13.0, weight: .medium)
    $0.text = "Colors"
  }

  private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.itemSize = ColorPickerView.itemSize
    layout.minimumInteritemSpacing = ColorPickerView.itemInterimSpacing
    layout.minimumLineSpacing = 0.0
    return layout
  }()

  public private(set) lazy var collectionView: UICollectionView = {
    let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    view.isPagingEnabled = true
    view.delegate = self
    view.dataSource = self
    view.showsHorizontalScrollIndicator = false
    view.backgroundColor = .clear
    view.clipsToBounds = false
    return view
  }()

  private func configureSelf() {
    backgroundColor = .fableBackgroundGray

    addBorder(.top, viewModel: FableBorderViewModel.regular)
  }

  private func configureLayout() {
    layoutMargins = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)

    addSubview(titleLabel)

    addSubview(collectionView)

    titleLabel.snp.makeConstraints { make in
      make.leading.equalTo(snp.leadingMargin)
      make.top.equalTo(snp.topMargin)
    }

    collectionView.snp.makeConstraints { make in
      make.leading.equalTo(snp.leadingMargin)
      make.trailing.equalTo(snp.trailingMargin)
      make.top.equalTo(titleLabel.snp.bottom).offset(20.0)
      make.height.equalTo(ColorPickerView.collectionViewHeight)
    }
  }

  public func randomColorHexStringFromSet() -> String? {
    colorHexStrings.value.randomElement()
  }
}

extension ColorPickerView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    ColorPickerView.itemSize
  }

  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: ColorPickerView.itemLineSpacing)
  }

  public func numberOfSections(in collectionView: UICollectionView) -> Int {
    sections.value.count
  }

  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    sections.value[section].items.count
  }

  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell: ColorCollectionViewCell = collectionView.dequeueReusableCell(at: indexPath)
    let item = sections.value[indexPath.section].items[indexPath.row]
    cell.colorHexString = item.colorHexString
    cell.mutableSelectedColorHexString <~ self.mutableSelectedColorHexString
      .producer.take(until: cell.reactive.prepareForReuse)
    return cell
  }

  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let colorHexString = sections.value[indexPath.section].items[indexPath.row].colorHexString
    mutableSelectedColorHexString.value = colorHexString
  }

  private class ColorCollectionViewCell: UICollectionViewCell {
    private let selectionContainer = UIView.create {
      $0.layer.cornerRadius = 10.0
      $0.layer.borderWidth = 1.0
      $0.layer.borderColor = UIColor.clear.cgColor
    }

    public var mutableSelectedColorHexString = MutableProperty<String?>(nil)
    public var colorHexString: String? {
      didSet {
        guard let colorHexString = colorHexString else { return }
        self.backgroundColor = UIColor(colorHexString)
      }
    }

    override init(frame: CGRect) {
      super.init(frame: .zero)
      configureSelf()
      configureLayout()
      configureReactive()
    }

    required init?(coder: NSCoder) {
      fatalError()
    }

    private func configureSelf() {
      layer.cornerRadius = 10.0
    }

    private func configureLayout() {
      addSubview(selectionContainer)

      selectionContainer.snp.makeConstraints { make in
        make.edges.equalTo(snp.edges).inset(UIEdgeInsets(top: -4.0, left: -4.0, bottom: -4.0, right: -4.0))
      }
    }

    private func configureReactive() {
      // maybe don't show selection?
      mutableSelectedColorHexString.producer.take(duringLifetimeOf: self).startWithValues { [weak self] selectedColorHexString in
        guard let self = self, let colorHexString = self.colorHexString else { return }
        self.selectionContainer.layer.borderColor = colorHexString == selectedColorHexString ?
          UIColor.fableDarkGray.cgColor : UIColor.clear.cgColor
      }
    }
  }
}
