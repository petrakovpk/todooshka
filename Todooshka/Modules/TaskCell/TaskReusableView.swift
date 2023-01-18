//
//  TaskReusableView.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 10.08.2021.
//

import UIKit

class TaskReusableView: UICollectionReusableView {
  static var reuseID: String = "TaskListReusableView"
  
  private let sectionHeaderLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .left
    label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    return label
  }()
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(sectionHeaderLabel)
    
    sectionHeaderLabel.anchor(
      top: topAnchor,
      left: leftAnchor,
      bottom: bottomAnchor,
      right: rightAnchor
    )
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(text: String) {
    sectionHeaderLabel.text = text
  }
}
