//
//  TaskTypeListCollectionViewCell.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 05.08.2021.
//

import UIKit
import RxFlow
import RxSwift
import RxCocoa
import Foundation
import SwipeCellKit

class TaskTypeListCollectionViewCell: SwipeCollectionViewCell {
  
  //MARK: - Properties
  static var reuseID: String = "TaskTypeListCollectionViewCell"
  var viewModel: TaskTypeListCollectionViewCellModel!
  var disposeBag = DisposeBag()
  
  //MARK: UI Elements
  private let imageView = UIImageView()
  private let label = UILabel()
  
  private let repeatButton = UIButton(type: .custom)
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    configureUI()
    bindViewModel()
    delegate = viewModel
  }

  //MARK: - Configure
  func configureUI() {
    contentView.cornerRadius = height / 2
    contentView.layer.borderWidth = 1
    contentView.layer.borderColor = UIColor(named: "taskTypeCellBorder")?.cgColor
    contentView.backgroundColor = UIColor(named: "taskTypeCellBackground")
    contentView.layer.masksToBounds = false
    
    imageView.contentMode = .scaleAspectFit

    contentView.addSubview(imageView)
    imageView.anchor(left: contentView.leftAnchor, leftConstant: 8, widthConstant: 40)
    imageView.anchorCenterYToSuperview()

    label.textAlignment = .left
    
    repeatButton.setImage(UIImage(named: "refresh-circle")?.original, for: .normal)
    repeatButton.backgroundColor = .blueRibbon
    repeatButton.cornerRadius = 25 / 2
    
    let attributedTitle = NSAttributedString(string: "Актививировать",
                                             attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 11, weight: .semibold)])
    repeatButton.setAttributedTitle(attributedTitle , for: .normal)
    repeatButton.setTitleColor(.white, for: .normal)
    repeatButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4);
    repeatButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0);
    
    contentView.addSubview(repeatButton)
    repeatButton.anchorCenterYToSuperview()
    repeatButton.anchor(right: contentView.rightAnchor, rightConstant: 4, widthConstant: 120, heightConstant: 25)
    
    contentView.addSubview(label)
    label.anchor(left: imageView.rightAnchor, right: repeatButton.leftAnchor, leftConstant: 8)
    label.anchorCenterYToSuperview()
  }
  
  func bindViewModel() {
    
    let input = TaskTypeListCollectionViewCellModel.Input(
      repeatButtonClickTrigger: repeatButton.rx.tap.asDriver()
    )
    
    let output = viewModel.transform(input: input)
    output.icon.drive(imageView.rx.image).disposed(by: disposeBag)
    output.color.drive(imageView.rx.tintColor).disposed(by: disposeBag)
    output.text.drive(label.rx.text).disposed(by: disposeBag)
    output.repeatButtonIsHidden.drive(repeatButton.rx.isHidden).disposed(by: disposeBag)
    output.repeatButtonClicked.drive().disposed(by: disposeBag)
  }
}
