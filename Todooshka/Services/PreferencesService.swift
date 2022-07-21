//
//  PreferencesService.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import RxSwift
import CoreData

protocol HasPreferencesService {
  var preferencesService: PreferencesService { get }
}

class PreferencesService {
  
  let formatter = DateFormatter()
  var needScrollToCurrentMonth: Bool = true
  
  init() {
    formatter.timeZone = TimeZone.current
  }
  
  func isOnboardingCompleted() -> Bool {
    return UserDefaults.standard.bool(forKey: "isOnboardingCompleted")
  }
  
}
