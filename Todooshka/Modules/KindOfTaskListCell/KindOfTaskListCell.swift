//
//  KindOfTaskListCell.swift
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

class KindOfTaskListCell: SwipeCollectionViewCell {
  
  // MARK: - Properties
  static var reuseID: String = "KindOfTaskListCell"
  
  var disposeBag = DisposeBag()
  
  // MARK: UI Elements
  let repeatButton = UIButton(type: .custom)
  
  private let imageView = UIImageView()
  private let label = UILabel()
  private let attributedTitle = NSAttributedString(
    string: "Актививировать",
    attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 11, weight: .semibold)])
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    configureUI()
  }
  
  // MARK: - Lifecycle
  override func prepareForReuse() {
    super.prepareForReuse()
    disposeBag = DisposeBag()
  }
  
  //MARK: - Configure
  func configureUI() {
    
    // adding
    contentView.addSubview(imageView)
    contentView.addSubview(repeatButton)
    contentView.addSubview(label)
    
    // contentView
    contentView.cornerRadius = height / 2
    contentView.layer.borderWidth = 1
    contentView.layer.borderColor = Theme.TaskType.Cell.border?.cgColor
    contentView.backgroundColor = Theme.TaskType.Cell.background
    contentView.layer.masksToBounds = false
    
    // imageView
    imageView.contentMode = .scaleAspectFit
    imageView.anchor(left: contentView.leftAnchor, leftConstant: 8, widthConstant: 40)
    imageView.anchorCenterYToSuperview()
    
    // repeatButton
    repeatButton.setImage(UIImage(named: "refresh-circle")?.original, for: .normal)
    repeatButton.backgroundColor = Palette.SingleColors.BlueRibbon
    repeatButton.cornerRadius = 25 / 2
    repeatButton.setAttributedTitle(attributedTitle , for: .normal)
    repeatButton.setTitleColor(.white, for: .normal)
    repeatButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4);
    repeatButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0);
    repeatButton.anchorCenterYToSuperview()
    repeatButton.anchor(right: contentView.rightAnchor, rightConstant: 4, widthConstant: 120, heightConstant: 25)
    
    // label
    label.textAlignment = .left
    label.anchor(left: imageView.rightAnchor, right: repeatButton.leftAnchor, leftConstant: 8)
    label.anchorCenterYToSuperview()
  }
  
  func configure(with kindOfTask: KindOfTask) {
    imageView.image = kindOfTask.icon.image
    imageView.tintColor = kindOfTask.color
    label.text = kindOfTask.text
    repeatButton.isHidden = kindOfTask.status == .active
  }
  
//  func bindViewModel() {
//
//    let input = TaskTypeListCollectionViewCellModel.Input(
//      repeatButtonClickTrigger: repeatButton.rx.tap.asDriver()
//    )
//
//    let outputs = viewModel.transform(input: input)
//
//    [
//      outputs.image.drive(imageView.rx.image),
//      outputs.color.drive(imageView.rx.tintColor),
//      outputs.text.drive(label.rx.text),
//      outputs.repeatButtonIsHidden.drive(repeatButton.rx.isHidden),
//      outputs.repeatButtonClicked.drive()
//    ]
//      .forEach({$0.disposed(by: disposeBag)})
//
//  }
}
