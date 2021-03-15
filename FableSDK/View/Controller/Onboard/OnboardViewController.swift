//
//  OnboardViewController.swift
//  AppFoundation
//
//  Created by Andrew Aquino on 3/27/19.
//

import AppFoundation
import AppUIFoundation
import FableSDKResolver
import FableSDKModelManagers
import FableSDKModelObjects
import FableSDKResourceManagers
import FableSDKUIFoundation
import FableSDKViewPresenters
import FableSDKViews
import FableSDKWireObjects
import NetworkFoundation
import ReactiveCocoa
import ReactiveSwift
import SnapKit
import UIKit


public class OnboardViewController: UIViewController {
  
  private let resolver: FBSDKResolver
  
  public init(
    resolver: FBSDKResolver
  ) {
    self.resolver = resolver
    super.init(nibName: nil, bundle: nil)
  }
  
  public required init?(coder: NSCoder) {
    fatalError()
  }
  
  private var currentPage: Int = 0
  private let pageImages = [#imageLiteral(resourceName: "onboardingHeaderFirst"), #imageLiteral(resourceName: "onobardingHeaderSecond"), #imageLiteral(resourceName: "onboardingHeaderThird")]
  private let pageTitles = ["Create", "Write", "Characters"]
  private let pageDescriptions = [
    "\n\nWrite your own tap fiction story and publish them for others to read!",
    "\n\nStart writing your story by tapping on a story block. Each story block represents a tap when reading.",
    "\n\nAssign characters to your story and have readers follow their journey.",
  ]

  // Inits the display image
  private let displayImage = UIImageView.new {
    let imageName = "onboarding_image1.png"
    let image = UIImage(named: imageName)
    $0.image = image
  }

  // Inits text view
  private let displayTextView = UITextView.new {
    $0.isEditable = false
    $0.isScrollEnabled = false
    $0.isSelectable = false
  }

  // Inits next button
  private let nextButton = UIButton.new {
    $0.tintColor = .black
    $0.setImage(#imageLiteral(resourceName: "onboardingNextButton"), for: .normal)
    $0.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
  }

  // Inits counter dots
  private let firstDot = UIImageView.new {
    let imageName = "pageActive.png"
    let image = UIImage(imageLiteralResourceName: imageName)
    let imageView = UIImageView(image: image)
    $0.image = image
  }

  private let secondDot = UIImageView.new {
    let imageName = "pageInactive.png"
    let image = UIImage(imageLiteralResourceName: imageName)
    let imageView = UIImageView(image: image)
    $0.image = image
  }

  private let thirdDot = UIImageView.new {
    let imageName = "pageInactive.png"
    let image = UIImage(imageLiteralResourceName: imageName)
    let imageView = UIImageView(image: image)
    $0.image = image
  }

  // Inits dot images using ImageLiteral, hard to see if you are using a dark background
  private let inactiveDot = #imageLiteral(resourceName: "pageInactive")
  private let activeDot = #imageLiteral(resourceName: "pageActive")

  override public func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    configureLayout()
    configureControls()
    initializeSwipeGesture()
  }

  // Creates swiping action
  func initializeSwipeGesture() {
    // sets up swiping to the left (next)
    let swipeNext = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(swipe:)))
    swipeNext.direction = .left
    view.addGestureRecognizer(swipeNext)

    // sets up swiping to the right (back)
    let swipeBack = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(swipe:)))
    swipeBack.direction = .right
    view.addGestureRecognizer(swipeBack)
  }

  // When swiped to next page...
  @objc func swipeLeft(swipe: UISwipeGestureRecognizer) {
    currentPage += 1
    updateSwipeContent()
  }

  // When swiped to previous page...
  @objc func swipeRight(swipe: UISwipeGestureRecognizer) {
    currentPage -= 1
    updateSwipeContent()
  }

  // Next button has been tapped
  @objc func nextButtonTapped() {
    currentPage += 1
    updateSwipeContent()
  }

  // Updates image and text based off tap count. If adding more pages update the case range below and change case 3 value.
  func updateSwipeContent() {
    switch currentPage {
    case -1: currentPage = 0
    case 0, 1, 2:
      updateViewAssets(pageNumber: currentPage)
    case 3:
      dismiss(animated: true, completion: nil)
    default:
      updateViewAssets(pageNumber: 0)
    }
  }

  private func updateViewAssets(pageNumber: Int) {
    UIView.animate(withDuration: 0.20, animations: {
      self.displayImage.alpha = 0
      self.displayTextView.alpha = 0
    }, completion: { _ in
      self.displayTextView.alpha = 1
      self.displayImage.alpha = 1
      self.displayImage.image = self.getDisplayImage(pageNumber: self.currentPage)
      self.displayTextView.attributedText = self.getDisplayText(pageNumber: self.currentPage)
    })
    switch currentPage {
    case 0:
      firstDot.image = activeDot
      secondDot.image = inactiveDot
      thirdDot.image = inactiveDot
    case 1:
      firstDot.image = inactiveDot
      secondDot.image = activeDot
      thirdDot.image = inactiveDot
    case 2:
      firstDot.image = inactiveDot
      secondDot.image = inactiveDot
      thirdDot.image = activeDot
    default:
      firstDot.image = activeDot
      secondDot.image = inactiveDot
      thirdDot.image = inactiveDot
    }
  }

  // Sets the display image for the current page number
  private func getDisplayImage(pageNumber: Int) -> UIImage {
    pageImages[pageNumber]
  }

  // Sets the page text for the current page number
  private func getDisplayText(pageNumber: Int) -> NSAttributedString {
    // Define paragraph style - you got to pass it along to NSAttributedString constructor
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center
    let titleStringValue = pageTitles[pageNumber]
    let descriptionStringValue = pageDescriptions[pageNumber]
    let attributedText = NSMutableAttributedString(string: titleStringValue, attributes: [.font: UIFont.fableFont(36, weight: .semibold), .paragraphStyle: paragraphStyle])
    attributedText.append(NSAttributedString(string: descriptionStringValue, attributes: [.font: UIFont.fableFont(18, weight: .medium), .foregroundColor: UIColor.black, .paragraphStyle: paragraphStyle]))
    return attributedText
  }

  // Sets image and text properties
  private func configureLayout() {
    view.backgroundColor = .white
    view.addSubview(displayImage)
    view.addSubview(displayTextView)
    displayTextView.attributedText = getDisplayText(pageNumber: 0)
    displayImage.image = getDisplayImage(pageNumber: 0)

    // Image icon constraints
    displayImage.snp.makeConstraints { make in
      make.centerX.equalTo(view.snp.centerX)
      make.bottom.equalTo(view.snp.centerY)
      make.width.equalTo(200)
      make.height.equalTo(200)
    }

    // Description contraints
    displayTextView.snp.makeConstraints { make in
      make.top.equalTo(displayImage.snp.bottom).offset(36)
      make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(20)
      make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-20)
      make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
      make.centerX.equalTo(view.snp.centerX)
    }
  }

  // Sets control buttons and counter
  private func configureControls() {
    view.addSubview(nextButton)
    view.addSubview(firstDot)
    view.addSubview(secondDot)
    view.addSubview(thirdDot)

    // Next button constraints
    nextButton.snp.makeConstraints { make in
      make.centerY.equalTo(firstDot.snp.centerY)
      make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-30)
      make.width.equalTo(45)
      make.height.equalTo(15)
    }

    // Dots constraints
    firstDot.snp.makeConstraints { make in
      make.leading.equalTo(view.snp.leading).offset(30)
      make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
      make.height.equalTo(10)
      make.width.equalTo(10)
    }

    secondDot.snp.makeConstraints { make in
      make.leading.equalTo(firstDot.snp.trailing).offset(7)
      make.centerY.equalTo(firstDot.snp.centerY)
      make.height.equalTo(10)
      make.width.equalTo(10)
    }

    thirdDot.snp.makeConstraints { make in
      make.leading.equalTo(secondDot.snp.trailing).offset(7)
      make.centerY.equalTo(firstDot.snp.centerY)
      make.height.equalTo(10)
      make.width.equalTo(10)
    }
  }
}
