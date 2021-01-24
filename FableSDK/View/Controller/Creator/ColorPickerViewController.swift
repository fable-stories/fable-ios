//
//  ColorPickerViewController.swift
//  AppFoundation
//
//  Created by Madan on 06/08/20.
//


import AppFoundation
import AppUIFoundation
import FableSDKResolver
import FableSDKModelObjects
import FableSDKUIFoundation
import FableSDKViewPresenters
import FableSDKViews
import Foundation
import ReactiveCocoa
import ReactiveSwift
import SnapKit
import UIKit

class ColorPickerViewController: UIViewController {
  
  private var mutableSelectedColorHexString: MutableProperty<String?>
  private var colorHexStrings: [String] = []
  private lazy var colorPickerView = ColorPickerView(
    mutableSelectedColorHexString: self.mutableSelectedColorHexString,
    colorHexStrings: Property(value: self.colorHexStrings)
  )

  public init(colorHexStrings: [String], mutableSelectedColorHexString: MutableProperty<String?>) {
    self.colorHexStrings = colorHexStrings
    self.mutableSelectedColorHexString = mutableSelectedColorHexString

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    configureSelf()
    configureLayout()
    configureReactive()
  }

  private func configureSelf() {

  }

  private func configureLayout() {
    view.addSubview(colorPickerView)
    colorPickerView.snp.makeConstraints { make in
      make.top.equalTo(view.snp.top)
      make.left.equalTo(view.snp.left)
      make.right.equalTo(view.snp.right)
      make.bottom.equalTo(view.snp.bottom)
    }
  }

  private func configureReactive() {

  }
}
