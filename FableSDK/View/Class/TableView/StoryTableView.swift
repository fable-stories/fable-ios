//
//  StoryTableView.swift
//  Fable
//
//  Created by Andrew Aquino on 10/1/19.
//

import AppFoundation
import AppUIFoundation
import FableSDKModelObjects
import ReactiveSwift
import SnapKit
import UIKit

public class StoryTableView: UITableView {
  private let stories: Property<[Story]>

  public init(stories: Property<[Story]>) {
    self.stories = stories
    super.init(frame: .zero, style: .grouped)
    configureSelf()
    configureReactive()
  }

  public required init?(coder: NSCoder) {
    fatalError()
  }

  private func configureSelf() {
    tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: CGFloat.leastNonzeroMagnitude, height: CGFloat.leastNonzeroMagnitude))
    separatorColor = .clear
    backgroundColor = .clear
    dataSource = self
    delegate = self
    register(StoryTableViewCell.self, forCellReuseIdentifier: StoryTableViewCell.reuseIdentifier)
  }

  private func configureReactive() {
    stories.producer.take(duringLifetimeOf: self).startWithValues { [weak self] _ in
      self?.reloadData()
    }
  }
}

extension StoryTableView: UITableViewDataSource, UITableViewDelegate {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    stories.value.count
  }

  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    StoryHorizontalDetailView.defaultHeight
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: StoryTableViewCell = dequeueReusableCell(at: indexPath)
    cell.storyView.story = stories.value[indexPath.row]
    return cell
  }
}

extension StoryTableView {
  public class StoryTableViewCell: UITableViewCell {
    public let storyView = StoryHorizontalDetailView()

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      configureSelf()
      configureLayout()
    }

    public required init?(coder: NSCoder) {
      fatalError()
    }

    private func configureSelf() {
      selectionStyle = .none
    }

    private func configureLayout() {
      contentView.addSubview(storyView)

      storyView.snp.makeConstraints { make in
        make.edges.equalTo(snp.edges)
      }
    }

    override public func prepareForReuse() {
      storyView.story = nil
      super.prepareForReuse()
    }
  }
}
