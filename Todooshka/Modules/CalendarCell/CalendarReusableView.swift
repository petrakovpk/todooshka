//
//  CalendarReusableView.swift
//  DragoDo
//
//  Created by Pavel Petakov on 22.01.2023.
//

import UIKit
import JTAppleCalendar

class CalendarReusableView: JTACMonthReusableView  {
  static var reuseID: String = "CalendarReusableView"
  
  public let monday: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
    label.text = "ПН"
    return label
  }()
  
  public let tuesday: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
    label.text = "ВТ"
    return label
  }()
  
  public let wednesday: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
    label.text = "СР"
    return label
  }()
  
  public let thursday: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
    label.text = "ЧТ"
    return label
  }()
  
  public let friday: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
    label.text = "ПТ"
    return label
  }()
  
  public let saturday: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
    label.text = "СБ"
    return label
  }()
  
  public let sunday: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
    label.text = "ВС"
    return label
  }()
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    let stackView = UIStackView(arrangedSubviews: [monday, tuesday, wednesday, thursday, friday, saturday, sunday])
    stackView.axis = .horizontal
    stackView.distribution = .fillEqually
    
    addSubview(stackView)
    
    stackView.anchor(
      top: topAnchor,
      left: leftAnchor,
      bottom: bottomAnchor,
      right: rightAnchor
    )
  }
}
