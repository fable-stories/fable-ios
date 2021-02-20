//
//  MarkdownViewController.swift
//  FableSDKViewControllers
//
//  Created by Enrique Florencio on 8/3/20.
//

import Foundation
import AppUIFoundation
import FableSDKResolver
import FableSDKUIFoundation
import FableSDKViewPresenters
import FableSDKViews
import SnapKit
import UIKit
import Down

class MarkdownViewController: UIViewController, UITextViewDelegate {
    
    /// The Terms of Service text that will be turned into Markdown text
    private let initialString: String
    /// The title for the View Controller
    private let navigationTitle: String
    
    /// The textview that will display the Markdown text
    private let markdownText = UITextView()
    
    /// Initialize the Terms of Service string and title for the view controller
    public init(initialString: String, navigationTitle: String) {
        self.initialString = initialString
        self.navigationTitle = navigationTitle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Set the textview delegate to this view controller
        self.markdownText.delegate = self
        /// Configure the layout for the view
        configureLayout()
        ///Configure the layout for the markDown text
        configureSelf()
    }
    
    func configureSelf() {
        /// Set the title of the view controller equal to the one passed into the init method
        navigationItem.title = navigationTitle
        view.backgroundColor = .fableWhite
        markdownText.backgroundColor = .fableWhite
        view.addSubview(markdownText)
        /// Set the constraints for the UITextView
        markdownText.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top).inset(12)
            make.leading.equalTo(view.snp.leading).inset(16)
            make.trailing.equalTo(view.snp.trailing).inset(16)
            make.bottom.equalTo(view.snp.bottom)
        }
        
        /// Convert the Terms of Service string into markdown code.
        let down = Down(markdownString: initialString)
        
        /// If we can't turn the markdown code into an attributed string then there is something fundamentally wrong with the program.
        guard let convertedText = try? down.toAttributedString() else {
            fatalError()
        }
        
        /// Set the UITextView attributed text to the markdown text
        markdownText.attributedText = convertedText
    }
    
    func configureLayout() {
        view.layoutMargins = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 20.0, right: 16.0)
        
    }
    
}

extension MarkdownViewController {
    static func makeTermsOfService() -> MarkdownViewController {
        return MarkdownViewController(initialString: "", navigationTitle: "Terms of Service")
    }
}


