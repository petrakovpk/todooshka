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
  
  let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ru_RU")
    formatter.dateFormat = "dd MMMM yyyy"
    return formatter
  }()
  
  let scrollToCurrentMonthTrigger = BehaviorRelay<(trigger: Bool, withAnimation: Bool)>(value: (false, false))
  
  var isOnboardingCompleted: Bool {
    UserDefaults.standard.bool(forKey: "isOnboardingCompleted")
  }
  
  
  init() {
    formatter.timeZone = TimeZone.current
  }
  
  
}
