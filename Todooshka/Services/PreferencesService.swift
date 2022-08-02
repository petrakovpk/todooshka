//
//  PreferencesService.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import RxSwift
import CoreData
import RxRelay

protocol HasPreferencesService {
  var preferencesService: PreferencesService { get }
}

class PreferencesService {
  
  let formatter = DateFormatter()
  var scrollToCurrentMonthTrigger = BehaviorRelay<(trigger: Bool, withAnimation: Bool)>(value: (false, false))
  
  init() {
    formatter.timeZone = TimeZone.current
  }
  
  func isOnboardingCompleted() -> Bool {
    return UserDefaults.standard.bool(forKey: "isOnboardingCompleted")
  }
  
}
