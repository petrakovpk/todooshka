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
  private let containerView = UIView()
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private let headerLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    return label
  }()
  
  private let descriptionTextView: UITextView = {
    let textView = UITextView()
    textView.font =  UIFont.systemFont(ofSize: 15, weight: .medium)
    textView.textAlignment = .center
    textView.isEditable = false
    textView.isSelectable = false
    return textView
  }()
  
  //MARK: - Draw
  override func draw(_ rect: CGRect) {
    configureUI()
    configureColor()
    bindToViewModel()
  }

  //MARK: - Bind to ViewModel
  func bindToViewModel() {
    let output = viewModel.transform()
    output.image.drive(imageView.rx.image).disposed(by: disposeBag)
    output.headerText.drive(headerLabel.rx.text).disposed(by: disposeBag)
    output.descriptionText.drive(descriptionTextView.rx.text).disposed(by: disposeBag)
  }
  
  //MARK: - Configure UI
  func configureUI() {
    contentView.addSubview(descriptionTextView)
    descriptionTextView.anchor(left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, leftConstant: 32, bottomConstant: 100, rightConstant: 32 , heightConstant: 90)
    descriptionTextView.anchorCenterXToSuperview()
    
    contentView.addSubview(headerLabel)
    headerLabel.anchor(bottom: descriptionTextView.topAnchor, bottomConstant: 26, heightConstant: 25)
    headerLabel.anchorCenterXToSuperview()

    contentView.addSubview(imageView)
    imageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: headerLabel.topAnchor, right: contentView.rightAnchor, leftConstant: 16, bottomConstant: 20, rightConstant: 16 )
    containerView.anchorCenterXToSuperview()
  }
  
}


extension OnboardingCollectionViewCell: ConfigureColorProtocol {
  func configureColor() {
    
    contentView.backgroundColor = .clear
    headerLabel.textColor = UIColor(named: "appText")
    
    descriptionTextView.backgroundColor = .clear
    descriptionTextView.textColor = .santasGray
  }
}
