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


class CalendarViewLayout: UICollectionViewFlowLayout {

  override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {

    // Определеяем collectionView
    guard let collectionView = self.collectionView else {
      return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
    }

    // Определяем видимые элементы
    let indexPathsForVisibleItems = collectionView.indexPathsForVisibleItems

    // Опрееделяем координаты минимальный и максимальный секции
    guard
      let minIndexPathsForVisibleItem = indexPathsForVisibleItems.min(by: { $0.section < $1.section }),
      let maxIndexPathsForVisibleItem = indexPathsForVisibleItems.max(by: { $0.section < $1.section }),
      let minLayoutAttributesForSupplementaryElement = collectionView.layoutAttributesForSupplementaryElement(ofKind: UICollectionView.elementKindSectionHeader, at: minIndexPathsForVisibleItem),
      let maxLayoutAttributesForSupplementaryElement = collectionView.layoutAttributesForSupplementaryElement(ofKind: UICollectionView.elementKindSectionHeader, at: maxIndexPathsForVisibleItem)
    else {
      return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
    }

    // Определяем текущую секцию
    let itemsForMinSection = indexPathsForVisibleItems.count(where: { $0.section == minIndexPathsForVisibleItem.section })
    let itemsForMaxSection = indexPathsForVisibleItems.count(where: { $0.section == maxIndexPathsForVisibleItem.section })
    let currentSection = itemsForMinSection > itemsForMaxSection ? minIndexPathsForVisibleItem.section : maxIndexPathsForVisibleItem.section

    // Определяем координаты текущей секции
    guard let currentSectionLayoutAttributesForSupplementaryElement = collectionView.layoutAttributesForSupplementaryElement(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: currentSection)) else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity) }

    invalidateLayout()
    prepare()
        
    // возвращаем скролл к нужной секции
    return CGPoint(x: 0, y: velocity.y == 0.0 ? currentSectionLayoutAttributesForSupplementaryElement.frame.origin.y : ( velocity.y < 0 ? minLayoutAttributesForSupplementaryElement.frame.origin.y : maxLayoutAttributesForSupplementaryElement.frame.origin.y ))
  }
}


