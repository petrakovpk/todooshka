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
  let showAlert = BehaviorRelay<Bool>(value: false)
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
    var logOutItem: SettingsItem!
    
    let showDeletedTaskTypesItem = SettingsItem(imageName: "trash", text: "Удаленные типы", type: .deletedTaskTypeListIsRequired)
    let showDeletedTasksItem = SettingsItem(imageName: "trash", text: "Удаленные задачи", type: .deletedTaskListIsRequired)
    
    services.networkAuthService.currentUser.bind{[weak self] currentUser in
      guard let self = self else { return }
      if currentUser != nil {
        logOutItem = SettingsItem(imageName: "logout", text: "Выйти", type: .authIsRequired)
      } else {
        logOutItem = SettingsItem(imageName: "login", text: "Войти", type: .authIsRequired)
      }
      self.dataSource.accept([UserProfileSettingsSectionModel(header: "Основные", items: [showDeletedTaskTypesItem, showDeletedTasksItem, logOutItem])])
    }.disposed(by: disposeBag)
  }
  
  
  func setOnboardedNotCompleted() {
    UserDefaults.standard.set(false, forKey: "isOnboardingCompleted")
  }
  
  func itemSelected(indexPath: IndexPath) {
    let item = dataSource.value[indexPath.section].items[indexPath.item]
    switch item.type {
    case .authIsRequired:
      handleAuthButtonClick()
    case .deletedTaskListIsRequired:
      steps.accept(AppStep.deletedTaskListIsRequired)
    case .deletedTaskTypeListIsRequired:
      steps.accept(AppStep.deletedTaskTypeListIsRequired)
    }
  }
  
  func handleAuthButtonClick() {
    if Auth.auth().currentUser == nil {
      steps.accept(AppStep.authIsRequired)
    } else {
      showAlert.accept(true)
    }
  }
  
  func leftBarButtonBackItemClick() {
    steps.accept(AppStep.userSettingsIsCompleted)
  }
  
  func alertCancelButtonClicked() {
    showAlert.accept(false)
  }
  
  func alertLogoutButtonClicked() {
    do {
      showAlert.accept(false)
      setOnboardedNotCompleted()
      try Auth.auth().signOut()
    }
    catch { print("already logged out") }
  }

}
