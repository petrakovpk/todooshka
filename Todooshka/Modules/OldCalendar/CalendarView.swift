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

  // MARK: - Init
  override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
    super.init(frame: frame, collectionViewLayout: layout)
    scrollsToTop = false
    showsVerticalScrollIndicator = false
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
