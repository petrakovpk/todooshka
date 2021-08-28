//
//  OnboardingPage.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 16.08.2021.
//


import UIKit

open class OnboardingPage: UIView {
    
    public var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.sizeToFit()
        return label
    }()

    public var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    public var headerTitle: UILabel = {
        let label = UILabel()
        label.text = "Sub Title"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.sizeToFit()
        return label
    }()
    
    public var headerTextView: UITextView = {
        let label = UITextView()
        label.text = "Sub Title"
        return label
    }()
    
    public let authButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Create an account or sign in", for: .normal)
        return button
    }()
    
    public let skipButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("SKIP", for: .normal)
        return button
    }()
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    
    func setUp() {
        
        
    }
}

