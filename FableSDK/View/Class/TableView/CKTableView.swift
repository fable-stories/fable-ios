//
//  CKTableView.swift
//  Fable
//
//  Created by Andrew Aquino on 11/29/19.
//

import AppFoundation
import UIKit

public class CKTableView: UITableView {
  public var onBackgroundSelect: VoidClosure?

  override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    let selectedCell = visibleCells.first(where: { cell in
      let point = cell.convert(point, from: self)
      return cell.point(inside: point, with: event)
    })
    if selectedCell == nil {
      onBackgroundSelect?()
      return false
    }
    return true
  }
}
