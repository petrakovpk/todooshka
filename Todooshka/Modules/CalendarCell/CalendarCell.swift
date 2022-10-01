//
//  CalendarCell.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.06.2021.
//


import UIKit
import RxSwift
import RxCocoa
import Foundation

class CalendarCell: UICollectionViewCell {
  
  // MARK: - Properties
  static var reuseID: String = "CalendarCell"
  
  // MARK: - UI Elements
  private let dateLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    return label
  }()
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  // MARK: - Draw
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    // adding
    contentView.addSubview(dateLabel)
    contentView.addSubview(imageView)
    
    // contentView
    contentView.cornerRadius = bounds.width / 2
    contentView.layer.borderColor = Theme.Cells.Calendar.Border.cgColor
    
    // dateLabel
    dateLabel.anchorCenterYToSuperview()
    dateLabel.anchorCenterXToSuperview()
    dateLabel.layer.zPosition = 1
    
    // imageView
    imageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor)
    imageView.layer.zPosition = 0
  }
  
  func configureAsEmpty() {
    contentView.borderWidth = 0.0
    contentView.backgroundColor = .clear
    imageView.image = nil
    dateLabel.text = nil
  }
  
  func configure(date: Date, isSelected: Bool, completedTasksCount: Int) {
    
    // contentView
    contentView.borderWidth = date.isInToday ? 1 : 0
    contentView.backgroundColor = isSelected ? Theme.Cells.Calendar.Selected : UIColor.clear
    
    // imageView
    imageView.image = getImage(count: completedTasksCount)
    
    // dateLabel
    dateLabel.text = date.day.string
    dateLabel.textColor = (imageView.image == nil) ? (isSelected ? UIColor.white : Theme.App.text) : Theme.Cells.Calendar.Text
    
  }
  
  func getImage(count: Int) -> UIImage? {
    switch count {
    case 1:
      return UIImage(named: "крылья_курица")
    case 2:
      return UIImage(named: "крылья_страус")
    case 3:
      return UIImage(named: "крылья_пингвин")
    case 4:
      return UIImage(named: "крылья_сова")
    case 5:
      return UIImage(named: "крылья_попугай")
    case 6:
      return UIImage(named: "крылья_орел")
    case 7 ... .max:
      return UIImage(named: "крылья_дракон")
    default:
      return nil
    }
  }
}

