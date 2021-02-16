//
//  FBSDKButtonNode.swift
//  FableSDKViews
//
//  Created by Andrew Aquino on 12/28/20.
//

import Foundation
import AsyncDisplayKit
import AppFoundation

private let primaryColor = UIColor("#1479FF")

public protocol FBSDKUIComponent {
  var uiComponentId: String { get }
}

public class FBSDKButtonNode: ASButtonNode, FBSDKUIComponent {
  public let uiComponentId: String = randomUUIDString()

  public enum ButtonKind {
    case primary
    case toggle
  }

  private let buttonKind: ButtonKind
  
  public override var isSelected: Bool {
    didSet {
      self.updateView()
    }
  }
  
  public override var isHighlighted: Bool {
    didSet {
      self.updateView()
    }
  }
  
  public var isLoading: Bool = false {
    didSet {
      ASPerformBlockOnMainThread {
        self.titleNode.alpha = self.isLoading ? 0.0 : 1.0
        self.activity.color = self.isSelected ? .white : primaryColor
        if self.isLoading {
          self.activity.startAnimating()
        } else {
          self.activity.stopAnimating()
        }
      }
    }
  }
  
  private lazy var activity: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView(style: .medium)
    let transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    view.transform = transform
    return view
  }()
  
  private lazy var activityContainer: ASDisplayNode = .new {
    let node = ASDisplayNode { [weak self] () -> UIView in
      guard let self = self else { return .init() }
      return self.activity
    }
    return node
  }

  public init(title: String = "", buttonKind: ButtonKind = .primary) {
    self.buttonKind = buttonKind
    super.init()
    self.contentEdgeInsets = .init(top: 4.0, left: 16.0, bottom: 4.0, right: 16.0)
    self.cornerRoundingType = .defaultSlowCALayer
    self.borderWidth = 1.0
    switch buttonKind {
    case .primary:
      self.cornerRadius = 8.0
    case .toggle:
      self.cornerRadius = 6.0
    }
    if title.isNotEmpty {
      self.setAttributedTitle(title.toAttributedString([
        .font: UIFont.systemFont(ofSize: 14.0, weight: .regular)
      ]), for: [.normal, .highlighted, .selected])
    }
    self.titleNode.flexGrow()
    self.updateView()
    
    self.addSubnode(activityContainer)
  }

  public override func didEnterDisplayState() {
    super.didEnterDisplayState()
    self.activityContainer.frame = .init(origin: .zero, size: self.calculatedSize)
  }

  public override func setAttributedTitle(_ title: NSAttributedString?, for state: UIControl.State) {
    if state.contains(.normal) {
      switch self.buttonKind {
      case .primary:
        super.setAttributedTitle(
          title?.mergingAttributes(
            [
              .paragraphStyle: NSMutableParagraphStyle(alignment: .center),
              .foregroundColor: UIColor.white
            ]
          ),
          for: .normal
        )
      case .toggle:
        super.setAttributedTitle(
          title?.mergingAttributes(
            [
              .paragraphStyle: NSMutableParagraphStyle(alignment: .center),
              .foregroundColor: primaryColor
            ]
          ),
          for: .normal
        )
      }
    }
    if state.contains(.selected) {
      switch self.buttonKind {
      case .primary:
        super.setAttributedTitle(
          title?.mergingAttributes(
            [
              .paragraphStyle: NSMutableParagraphStyle(alignment: .center),
              .foregroundColor: primaryColor
            ]
          ),
          for: .selected
        )
      case .toggle:
        super.setAttributedTitle(
          title?.mergingAttributes(
            [
              .paragraphStyle: NSMutableParagraphStyle(alignment: .center),
              .foregroundColor: UIColor.white
            ]
          ),
          for: .selected
        )
      }
    }
    if state.contains(.highlighted) {
      switch self.buttonKind {
      case .primary:
        super.setAttributedTitle(
          title?.mergingAttributes(
            [
              .paragraphStyle: NSMutableParagraphStyle(alignment: .center),
              .foregroundColor: primaryColor
            ]
          ),
          for: .highlighted
        )
      case .toggle:
        super.setAttributedTitle(
          title?.mergingAttributes(
            [
              .paragraphStyle: NSMutableParagraphStyle(alignment: .center),
              .foregroundColor: isSelected ? UIColor.white : primaryColor
            ]
          ),
          for: .highlighted
        )
      }
    }
  }

  @objc private func updateView() {
    switch self.buttonKind {
    case .primary:
      self.backgroundColor = (isHighlighted || isSelected) ? UIColor.white : primaryColor
      self.borderColor = ((isHighlighted || isSelected) ? primaryColor : UIColor.clear).cgColor
    case .toggle:
      if self.isHighlighted {
        self.backgroundColor = isSelected ? primaryColor : UIColor.white
        self.borderColor = (isSelected ? primaryColor : UIColor.clear).cgColor
      } else {
        self.backgroundColor = isSelected ? primaryColor : UIColor.white
        self.borderColor = (isSelected ? UIColor.clear : primaryColor).cgColor
      }
    }
  }
}
