//
//  Point.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 10.02.2022.
//

import Foundation

struct GameCurrency {
  let UID: String
  let currency: Currency
  let created: Date
  let taskUID: String
  
  // MARK: - Init
  init(UID: String, currency: Currency, created: Date, task: Task) {
    self.UID = UID
    self.currency = currency
    self.created = created
    self.taskUID = task.UID
  }
  
  init?(gameCurrencyCoreData: GameCurrencyCoreData) {
    guard let currency = Currency(rawValue: gameCurrencyCoreData.currency) else { return nil }
    self.UID = gameCurrencyCoreData.uid
    self.currency = currency
    self.created = gameCurrencyCoreData.created
    self.taskUID = gameCurrencyCoreData.taskUID
  }
}
