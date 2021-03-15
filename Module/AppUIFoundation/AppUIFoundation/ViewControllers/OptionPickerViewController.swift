//
//  OptionPickerViewController.swift
//  AppUIFoundation
//
//  Created by Andrew Aquino on 7/27/19.
//

import UIKit
import AppFoundation
import ReactiveSwift
import SnapKit

public protocol OptionPickerViewControllerConfiguration {
  var configuration: OptionPickerViewController.Configuration { get }
}

public class OptionPickerViewController: UIViewController {
  public struct Option: Hashable {
    public let optionId: String
    public let attributedTitle: NSAttributedString
    public init(optionId: String, attributedTitle: NSAttributedString) {
      self.optionId = optionId
      self.attributedTitle = attributedTitle
    }
  }
  
  public struct Configuration: OptionPickerViewControllerConfiguration {
    
    public let title: Property<String>
    public let initialSelectionIds: Set<String>
    public let options: Property<[Option]>

    public init(
      title: Property<String>,
      initialSelectionIds: Set<String>,
      options: Property<[Option]>
    ) {
      self.title = title
      self.initialSelectionIds = initialSelectionIds
      self.options = options
    }
    
    public var configuration: OptionPickerViewController.Configuration { return self }
  }
  
  public private(set) lazy var selectedOptions: Property<Set<OptionPickerViewController.Option>>
    = mutableSelectedOptions.map { $0 }
  private let mutableSelectedOptions = MutableProperty<Set<Option>>([])

  private let configuration: Configuration
  
  public init(_ configuration: OptionPickerViewControllerConfiguration) {
    self.configuration = configuration.configuration
    super.init(nibName: nil, bundle: nil)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError()
  }
  
  private lazy var tableView = UITableView.new {
    $0.separatorColor = .clear
    $0.delegate = self
    $0.dataSource = self
    $0.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    configureSelf()
    configureLayout()
    
    configuration.options.signal.take(duringLifetimeOf: self).observeValues { [weak self] _ in
      self?.tableView.reloadData()
    }
  }
  
  private func configureSelf() {
    view.backgroundColor = .white
    
    navigationItem.reactive.title <~ configuration.title
  }
  
  private func configureLayout() {
    view.addSubview(tableView)
    
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(view)
    }
  }
}

extension OptionPickerViewController: UITableViewDelegate, UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return configuration.options.value.count
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let option = configuration.options.value[indexPath.row]
    let cell: UITableViewCell = tableView.dequeueReusableCell(at: indexPath)
    cell.textLabel?.attributedText = option.attributedTitle
    return cell
  }
  
  // TODO: MVP - for now one option is always selected
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    let option = configuration.options.value[indexPath.row]
    mutableSelectedOptions.value.removeAll()
    mutableSelectedOptions.value.insert(option)
  }
  
  public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let option = configuration.options.value[indexPath.row]
    let isSelected = configuration.initialSelectionIds.contains(option.optionId)
    if isSelected {
      tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
    }
  }
}
