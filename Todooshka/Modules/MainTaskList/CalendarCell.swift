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
  
  private let leftDot: UIView = {
    let view = UIView()
    view.cornerRadius = 2
    view.isHidden = true
    view.backgroundColor = Palette.SingleColors.Shamrock
    return view
  }()
  
  private let centralDot: UIView = {
    let view = UIView()
    view.cornerRadius = 2
    view.isHidden = true
    view.backgroundColor = Palette.SingleColors.JungleGreen
    return view
  }()
  
  private let rightDot: UIView = {
    let view = UIView()
    view.cornerRadius = 2
    view.isHidden = true
    view.backgroundColor = Palette.SingleColors.Jevel
    return view
  }()
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    let dotsStackView = UIStackView(arrangedSubviews: [leftDot, centralDot, rightDot])
    
    cornerRadius = bounds.width / 2
    
    contentView.cornerRadius = bounds.width / 2
    contentView.borderColor = Style.Cells.Calendar.Selected
    contentView.addSubviews([
      imageView,
      dateLabel,
      dotsStackView
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
    
    leftDot.anchor(
      widthConstant: 4,
      heightConstant: 4)
    
    centralDot.anchor(
      widthConstant: 4,
      heightConstant: 4)
    
    rightDot.anchor(
      widthConstant: 4,
      heightConstant: 4)
    
    dotsStackView.anchorCenterXToSuperview()
    dotsStackView.anchorCenterYToSuperview(constant: 10)
    dotsStackView.anchor(
      topConstant: 4,
      heightConstant: 4)
    
  }
  
  func configure(cellState: CellState, selectedDate: Date, completedTasksCount: Int, plannedTasksCount: Int) {
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
    
    if cellState.date.startOfDay <= Date().startOfDay {
      leftDot.isHidden = true
      centralDot.isHidden = true
      rightDot.isHidden = true
    } else {
      switch plannedTasksCount {
      case 0:
        leftDot.isHidden = true
        centralDot.isHidden = true
        rightDot.isHidden = true
      case 1:
        leftDot.isHidden = false
        centralDot.isHidden = true
        rightDot.isHidden = true
      case 2:
        leftDot.isHidden = false
        centralDot.isHidden = false
        rightDot.isHidden = true
      case 3 ... Int.max:
        leftDot.isHidden = false
        centralDot.isHidden = false
        rightDot.isHidden = false
      default:
        leftDot.isHidden = true
        centralDot.isHidden = true
        rightDot.isHidden = true
      }
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
