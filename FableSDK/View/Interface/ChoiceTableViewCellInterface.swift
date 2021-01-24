//
//  ChoiceTableViewCellInterface.swift
//  Fable
//
//  Created by Andrew Aquino on 11/16/19.
//

import AppFoundation
import FableSDKModelObjects
import UIKit

public protocol ChoiceGroupTableViewCellProtocol {
  var message: Message? { get }
}

public protocol ChoiceGroupTableViewCellDelegate: ChoiceRowViewDelegate {
  func choiceGroupTableViewCell(
    controlStateForChoice choiceId: Int,
    cell: ChoiceGroupTableViewCellProtocol
  ) -> UIControl.State
}

public protocol ChoiceRowViewProtocol {
  var choice: Choice { get }
  var controlState: UIControl.State { get }
}

public protocol ChoiceRowViewDelegate: AnyObject {
  func choiceRowView(
    choiceSelected choiceId: Int,
    cell: ChoiceRowViewProtocol
  )
  func choiceRowView(
    textViewEditEvent event: UITextView.EditEvent,
    for choiceId: Int,
    cell: ChoiceRowViewProtocol
  )
}
