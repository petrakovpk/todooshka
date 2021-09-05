//
//  OnboardingCollectionViewCell.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.08.2021.
//

import UIKit
import RxSwift
import RxCocoa
import Foundation
import SwipeCellKit

class OnboardingCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Properties
    var disposeBag = DisposeBag()
    var viewModel: OnboardingCollectionViewCellModel!
    
    static var reuseID: String = "OnboardingCollectionViewCell"
    
    //MARK: - UI Elements
    lazy var contentImageView = UIView()
    lazy var imageView = UIImageView()
    lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font =  UIFont.systemFont(ofSize: 15, weight: .medium)
        //textView.textColor = UIColor(red: 0.583, green: 0.592, blue: 0.696, alpha: 1)
        //textView.backgroundColor = UIColor.clear
        textView.textAlignment = .center
        textView.isEditable = false
        textView.isSelectable = false
        return textView
    }()
    
    
    //MARK: - Bind to ViewModel
    func bindToViewModel(viewModel: OnboardingCollectionViewCellModel){
        self.viewModel = viewModel
        
        configureUI()
        setViewColor()
        
        viewModel.imageOutput.bind(to: imageView.rx.image).disposed(by: disposeBag)
        viewModel.headerTextOutput.bind(to: headerLabel.rx.text).disposed(by: disposeBag)
        viewModel.descriptionTextOutput.bind(to: descriptionTextView.rx.text).disposed(by: disposeBag)
    }
    
    //MARK: - Configure UI
    func configureUI() {
        contentView.addSubview(descriptionTextView)
        descriptionTextView.anchor(left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, leftConstant: 16, bottomConstant: 200, rightConstant: 16 , heightConstant: 45)
        descriptionTextView.anchorCenterXToSuperview()
        
        contentView.addSubview(headerLabel)
        headerLabel.anchor(bottom: descriptionTextView.topAnchor, bottomConstant: 26, heightConstant: 25)
        headerLabel.anchorCenterXToSuperview()
        
        contentView.addSubview(contentImageView)
        contentImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: headerLabel.topAnchor, right: contentView.rightAnchor, bottomConstant: 40)
        contentImageView.anchorCenterXToSuperview()
                
        contentImageView.addSubview(imageView)
        imageView.anchor(top: contentImageView.topAnchor)
        imageView.anchorCenterXToSuperview()
    }
    
}



