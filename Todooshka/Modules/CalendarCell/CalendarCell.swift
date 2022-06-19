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
    contentView.layer.borderColor = Theme.UserProfile.Calendar.Cell.border?.cgColor
    
    // dateLabel
    dateLabel.anchorCenterYToSuperview()
    dateLabel.anchorCenterXToSuperview()
    dateLabel.layer.zPosition = 1
    
    // imageView
    imageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor)
    imageView.layer.zPosition = 0
  }
  
  func configure(calendarDay: CalendarDay) {
    
    // contentView
    contentView.borderWidth = calendarDay.date.isInToday ? 1 : 0
    contentView.backgroundColor = calendarDay.isSelected ? Theme.UserProfile.Calendar.Cell.selectedBackground : UIColor.clear
    
    // imageView
    imageView.image = getImage(count: calendarDay.completedTasksCount)
    
    // dateLabel
    dateLabel.text = calendarDay.date.day.string
    dateLabel.textColor = imageView.image == nil ? calendarDay.isSelected ? UIColor.white : Theme.App.text : UIColor(hexString: "#030410")
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

