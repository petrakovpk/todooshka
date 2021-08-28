//
//  UserProfileSettingsViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 14.06.2021.
//


import RxFlow
import RxSwift
import RxCocoa
import Firebase
import UIKit
import CoreData

class UserProfileSettingsViewModel: Stepper {
    
    let steps = PublishRelay<Step>()
    let dataSource = BehaviorRelay<[UserProfileSettingsSectionModel]>(value: [])
    
    private let services: AppServices
    private let disposeBag = DisposeBag()

    init(services: AppServices) {
        self.services = services
        var logOutItem: SettingsItem!
        
        let showDeletedTasksItem = SettingsItem(imageName: "trash", text: "Удаленные задачи")
       
        services.networkAuthService.currentUser.bind{[weak self] currentUser in
            guard let self = self else { return }
            if currentUser != nil {
                logOutItem = SettingsItem(imageName: "logout", text: "Выйти")
            } else {
                logOutItem = SettingsItem(imageName: "login", text: "Войти")
            }
            self.dataSource.accept([UserProfileSettingsSectionModel(header: "Основные", items: [showDeletedTasksItem, logOutItem])])
        }.disposed(by: disposeBag)
    }
    
    func alertButtonClick(buttonIndex: Int){
        switch buttonIndex {
        case 0:
            setOnboardedNotCompleted()
            logOut()
        default:
            print(buttonIndex)
        }
    }
    
    func setOnboardedNotCompleted() {
        UserDefaults.standard.set(false, forKey: "isOnboardingCompleted")
    }
    
    func itemSelected(indexPath: IndexPath) {
        switch indexPath.item {
        case 0:
            steps.accept(AppStep.deletedTaskListIsRequired)
        default:
            print("Жопа джуси")
        }
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
        }
        catch { print("already logged out") }
    }
    
    func leftBarButtonBackItemClick() {
        steps.accept(AppStep.userSettingsIsCompleted)
    }
    
    func logUserIn() {
        steps.accept(AppStep.authIsRequired)
    }
}
