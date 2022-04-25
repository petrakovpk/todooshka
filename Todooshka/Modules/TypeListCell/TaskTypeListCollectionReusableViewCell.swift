//
//  TaskTypeListCollectionReusableViewCell.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 12.09.2021.
//


import UIKit

class TaskTypeListCollectionReusableViewCell: UICollectionReusableView {
  
  //MARK: - Properties
  static let reuseID: String = "TaskTypeListCollectionReusableViewCell"
  
  private let headerLabel = UILabel()

  //MARK: - Init
  override init(frame: CGRect){
    super.init(frame: frame)
    
    addSubview(headerLabel)
    headerLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
    
    headerLabel.textAlignment = .left
    headerLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(text: String) {
    headerLabel.text = text
  }
}


