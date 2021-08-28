//
//  PreferencesService.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import Firebase
import RxSwift
import CoreData

protocol HasPreferencesService {
    var preferencesService: PreferencesService { get }
}

class PreferencesService {
    
    let formatter = DateFormatter()
    
    init() {
        formatter.timeZone = TimeZone.current
    }

    func isUserLoggedin() -> Bool {
        return !(Auth.auth().currentUser == nil)
    }
    
    func isOnboardingCompleted() -> Bool {
        return UserDefaults.standard.bool(forKey: "isOnboardingCompleted")
    }

}
