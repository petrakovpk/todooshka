//
//  FunItemNoMoreTasksCell.swift
//  DragoDo
//
//  Created by Pavel Petakov on 13.04.2023.
//

import Lottie
import SkeletonView
import UIKit

class FunItemNoMoreTasksCell: UITableViewCell {
  static var reuseID: String = "FunItemNoMoreTasksCell"
  
  private let loadMoreTasksButton: UIButton = {
    let button = UIButton(type: .system)
    button.layer.cornerRadius = 5
    button.setTitle("Загрузить больше задач", for: .normal)
    return button
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
 
  private func setupUI() {
    backgroundColor = Style.App.background
    selectionStyle = .none
    contentView.addSubviews([
      loadMoreTasksButton
    ])
    
    setupConstraints()
  }
  
  private func setupConstraints() {
    loadMoreTasksButton.anchorCenterXToSuperview()
    loadMoreTasksButton.anchorCenterYToSuperview()
  }
}

