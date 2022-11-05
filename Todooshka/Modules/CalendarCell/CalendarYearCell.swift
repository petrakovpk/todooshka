//
//  CalendarYearCell.swift
//  Todooshka
//
//  Created by Pavel Petakov on 21.07.2022.
//

import UIKit
import RxSwift
import RxCocoa
import Foundation

class CalendarYearCell: UICollectionViewCell {

  // MARK: - Properties
  static var reuseID: String = "CalendarYearCell"

  // MARK: - UI Elements
  private let label: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    return label
  }()

  // MARK: - Draw
  override func draw(_ rect: CGRect) {
    super.draw(rect)

    // adding
    contentView.addSubview(label)

    // dateLabel
    label.anchorCenterYToSuperview()
    label.anchorCenterXToSuperview()
  }

  func configure(year: Int) {
    label.text = year.string
  }
}
