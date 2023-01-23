//
//  JTAppleCell.swift
//  DragoDo
//
//  Created by Pavel Petakov on 20.01.2023.
//

import JTAppleCalendar
import UIKit

class CalendarCell: JTACDayCell {
  static var reuseID: String = "CalendarCell"
  
  public let dateLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    return label
  }()
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    cornerRadius = bounds.width / 2
    
    contentView.cornerRadius = bounds.width / 2
    contentView.borderColor = Style.Cells.Calendar.Selected
    contentView.addSubview(dateLabel)
    
    dateLabel.anchor(
      top: contentView.topAnchor,
      left: contentView.leftAnchor,
      bottom: contentView.bottomAnchor,
      right: contentView.rightAnchor
    )
  }
}
