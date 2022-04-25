//
//  Point.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 10.02.2022.
//

import Foundation

struct Point {
  let UID: String
  let currency: Currency
  let created: Date
  
  // MARK: - Init
  init(UID: String, currency: Currency, created: Date) {
    self.UID = UID
    self.currency = currency
    self.created = created
  }
  
  init?(pointCoreData: PointCoreData) {
    guard let currency = Currency(rawValue: pointCoreData.currency) else { return nil }
    self.UID = pointCoreData.uid
    self.currency = currency
    self.created = pointCoreData.created
  }
}
