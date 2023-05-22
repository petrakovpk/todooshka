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
  
  private let wingsImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private let isSelectedView: UIView = {
    let view = UIView()
    view.backgroundColor = Palette.SingleColors.BlueRibbon
    return view
  }()
  
  private let isTodayView: UIView = {
    let view = UIView()
    view.layer.borderColor = Palette.SingleColors.BlueRibbon.cgColor
    return view
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

    contentView.addSubviews([
      isSelectedView,
      isTodayView,
      wingsImageView,
      dateLabel,
      dotsStackView
    ])
    
    isSelectedView.cornerRadius = min(bounds.height, bounds.width) / 2
    isSelectedView.anchorCenterXToSuperview()
    isSelectedView.anchorCenterYToSuperview()
    isSelectedView.anchor(
      widthConstant: min(bounds.height, bounds.width),
      heightConstant: min(bounds.height, bounds.width)
    )
    
    isTodayView.cornerRadius = min(bounds.height, bounds.width) / 2
    isTodayView.anchorCenterXToSuperview()
    isTodayView.anchorCenterYToSuperview()
    isTodayView.anchor(
      widthConstant: min(bounds.height, bounds.width),
      heightConstant: min(bounds.height, bounds.width)
    )
    
    dateLabel.anchor(
      top: contentView.topAnchor,
      left: contentView.leftAnchor,
      bottom: contentView.bottomAnchor,
      right: contentView.rightAnchor)
    
    wingsImageView.anchor(
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
  
  func clear() {
    isHidden = true
    backgroundColor = .clear
    
    dateLabel.textColor = Style.App.text
    dateLabel.text = ""
    
    wingsImageView.image = nil
    
    leftDot.isHidden = true
    centralDot.isHidden = true
    rightDot.isHidden = true
  }
  
  func configure(cellState: CellState, isSelected: Bool, completedTasksCount: Int, plannedTasksCount: Int) {
    dateLabel.text = cellState.text
    wingsImageView.image = getImage(count: completedTasksCount)

    if cellState.dateBelongsTo == .thisMonth {
      if isSelected {
        isSelectedView.backgroundColor = Style.Cells.Calendar.Selected
        dateLabel.textColor = completedTasksCount == 0 ? .white : Style.App.text
      } else {
        isSelectedView.backgroundColor = .clear
        dateLabel.textColor = Style.App.text
      }
    } else {
      isSelectedView.backgroundColor = .clear
      dateLabel.textColor = .lightGray
    }
    
    if cellState.date.startOfDay == Date().startOfDay {
      isTodayView.borderWidth = 1.0
    } else {
      isTodayView.borderWidth = 0
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
