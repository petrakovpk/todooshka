//
//  TaskTypeIconCollectionViewCell.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 07.09.2021.
//

import UIKit
import RxSwift
import RxCocoa


class TaskTypeIconCollectionViewCell: UICollectionViewCell {
  
  //MARK: - Properties
  static var reuseID: String = "TaskTypeIconCollectionViewCell"
  var viewModel: TaskTypeIconCollectionViewCellModel!
  var disposeBag = DisposeBag()
  
  //MARK: - UI Elements
  private let imageView = UIImageView()
  
  //MARK: - Configure UI
  func configureUI() {
    contentView.addSubview(imageView)
    imageView.anchorCenterXToSuperview()
    imageView.anchorCenterYToSuperview()
    
    imageView.tintColor = UIColor(named: "appText")
  }
  
  //MARK: - Bind to ViewModel
  func bindToViewModel(viewModel: TaskTypeIconCollectionViewCellModel){
    self.viewModel = viewModel
    
    configureUI()
    
    viewModel.taskTypeIcon.bind{ self.imageView.image = $0?.image }.disposed(by: disposeBag)
    
  }
  
  
}


