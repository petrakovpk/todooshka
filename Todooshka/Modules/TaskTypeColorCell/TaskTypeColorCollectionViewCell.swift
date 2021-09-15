//
//  TaskTypeColorCollectionViewCell.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 15.09.2021.
//

import UIKit
import RxSwift
import RxCocoa

class TaskTypeColorCollectionViewCell: UICollectionViewCell {
  
  //MARK: - Properties
  static var reuseID: String = "TaskTypeColorCollectionViewCell"
  var viewModel: TaskTypeColorCollectionViewCellModel!
  var disposeBag = DisposeBag()
  
  //MARK: - Draw
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    contentView.cornerRadius = contentView.bounds.height / 2
    contentView.borderColor = UIColor(named: "appText")
  }
  
  //MARK: - Bind to ViewModel
  func bindTo(viewModel: TaskTypeColorCollectionViewCellModel){
    self.viewModel = viewModel
    
    contentView.backgroundColor = viewModel.taskTypeColorItem.value?.color
  
    viewModel.isSelected.bind{ [weak self] isSelected in
      guard let self = self else { return }
      self.contentView.borderWidth = isSelected ? 2.0 : 0.0
    }.disposed(by: disposeBag)
    
    //viewModel.taskTypeIcon.bind{ self.imageView.image = $0?.image }.disposed(by: disposeBag)
    
  }
}
