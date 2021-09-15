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
  
  //MARK: - Draw
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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
  
  func bindTo(viewModel: TaskTypeListCollectionViewCellModel) {
    self.viewModel = viewModel
  
    delegate = viewModel
    
    disposeBag = DisposeBag()
    
    repeatButton.rx.tapGesture().when(.recognized).bind{ _ in viewModel.repeatButtonClicked()}.disposed(by: disposeBag)
    
    viewModel.type.bind{ [weak self] type in
      guard let self = self else { return }
      guard let type = type else { return }
          
      self.imageView.image = type.image
      self.imageView.tintColor = type.imageColor
      
      self.label.text = type.text
      
      self.repeatButton.isHidden = (type.status == .active)
    }.disposed(by: disposeBag)


  }
}
