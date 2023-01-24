//
//  JTAppleswift
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
    label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    label.layer.zPosition = 1
    return label
  }()
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    cornerRadius = bounds.width / 2
    
    contentView.cornerRadius = bounds.width / 2
    contentView.borderColor = Style.Cells.Calendar.Selected
    contentView.addSubviews([
      imageView,
      dateLabel
    ])
    
    dateLabel.anchor(
      top: contentView.topAnchor,
      left: contentView.leftAnchor,
      bottom: contentView.bottomAnchor,
      right: contentView.rightAnchor)
    
    imageView.anchor(
      top: contentView.topAnchor,
      left: contentView.leftAnchor,
      bottom: contentView.bottomAnchor,
      right: contentView.rightAnchor)
    
    
  }
  
  func configure(cellState: CellState, selectedDate: Date, completedTasksCount: Int) {
    dateLabel.text = cellState.text
    imageView.image = getImage(count: completedTasksCount)
    
    if cellState.date.startOfDay == selectedDate.startOfDay {
      backgroundColor = Style.Cells.Calendar.Selected
      dateLabel.textColor = completedTasksCount == 0 ? .white : Style.App.text
    } else {
      backgroundColor = .clear
      dateLabel.textColor = Style.App.text
    }

    if cellState.date.startOfDay == Date().startOfDay {
      contentView.borderWidth = 1.0
    } else {
      contentView.borderWidth = 0
    }
    
    if cellState.dateBelongsTo == .thisMonth {
      isHidden = false
    } else {
      isHidden = true
    }
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
