//
//  CalendarReusableView.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 10.06.2021.
//

import UIKit

class CalendarReusableView: UICollectionReusableView {
  
  // MARK: - Properties
  static var reuseID: String = "CalendarReusableView"
  
  // MARK: - UI elements
  public let label = UILabel()
  
  // MARK: - draw
  override func draw(_ rect: CGRect) {
    addSubview(label)
    label.anchorCenterYToSuperview()
    label.anchor(left: leftAnchor, leftConstant: 16)
  }
}

