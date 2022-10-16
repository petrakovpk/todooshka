//
//  CalendarView.swift
//  Todooshka
//
//  Created by Pavel Petakov on 26.07.2022.
//

import UIKit

protocol CalendarViewDelegate {
  func appendPastData()
  func appendFutureData()
}

class CalendarView: UICollectionView {
  
  // MARK: - Delegate
  public var calendarViewDelegate: CalendarViewDelegate?
  
  // MARK: - Init
  override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
    let layout = layout as! UICollectionViewFlowLayout
    layout.minimumInteritemSpacing = Sizes.Views.Calendar.minimumLineSpacing
    layout.minimumLineSpacing = Sizes.Views.Calendar.minimumLineSpacing
    super.init(frame: frame, collectionViewLayout: layout)
    register(CalendarCell.self, forCellWithReuseIdentifier: CalendarCell.reuseID )
    register(CalendarYearCell.self, forCellWithReuseIdentifier: CalendarYearCell.reuseID )
    register(CalendarReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CalendarReusableView.reuseID)
    backgroundColor = UIColor.clear
    showsVerticalScrollIndicator = false
    scrollsToTop = false
    delaysContentTouches = false
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    if contentOffset.y < 300 {
      calendarViewDelegate?.appendPastData()
    }
  }
  
}

