//
//  ChapterPresenter.swift
//  Fable
//
//  Created by Andrew Aquino on 12/15/19.
//

import FableSDKModelObjects
import Foundation
import ReactiveSwift

public class ChapterPresenter {
  private let model: CKModelReadOnly

  public init(model: CKModelReadOnly) {
    self.model = model
  }
}
