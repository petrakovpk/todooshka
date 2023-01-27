//
//  PreferencesService.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import CoreData
import Firebase
import RxRelay
import RxSwift

protocol HasPreferencesService {
  var preferencesService: PreferencesService { get }
}

class PreferencesService {
  
  public let workplaceScrollToPageIndex = PublishRelay<Int>()
  
  public var applicationDocumentsDirectory: URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
  }

  init() {
    
  }

}
