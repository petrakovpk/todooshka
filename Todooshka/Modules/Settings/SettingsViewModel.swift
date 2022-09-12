//
//  SettingsViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 14.06.2021.
//

import CoreData
import FirebaseAuth
import RxFlow
import RxSwift
import RxCocoa
import UIKit

class SettingsViewModel: Stepper {
  
  let services: AppServices
  let steps = PublishRelay<Step>()
  
  private let dataSource = BehaviorRelay<[SettingsCellSectionModel]>(value: [])
  private let showAlert = BehaviorRelay<Bool>(value: false)
  
  struct Input {
    let backButtonClickTrigger: Driver<Void>
    let selection: Driver<IndexPath>
  }
  
  struct Output {
    let backButtonClick: Driver<Void>
    let itemSelected: Driver<Void>
    let dataSource: Driver<[SettingsCellSectionModel]>
  }
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  func transform(input: Input) -> Output {
    
    let currentUser = Auth.auth().rx.stateDidChange.asDriver(onErrorJustReturn: nil)
    
    // auth
    let logInIsRequired = SettingsItem(imageName: "login", text: "Войти в аккаунт", type: .logInIsRequired)
    let userProfileIsRequired = SettingsItem(imageName: "user-square", text: Auth.auth().currentUser?.displayName ?? "Герой без имени" , type: .userProfileIsRequiared)
    //data
    let saveDataIsRequired = SettingsItem(imageName: "box-add", text: "Сохранить данные", type: .saveDataIsRequired)
    let loadDataIsRequired = SettingsItem(imageName: "box-tick", text: "Загрузить данные", type: .loadDataIsRequired)
    // deleted
    let deletedTaskTypeListIsRequired = SettingsItem(imageName: "trash", text: "Типы", type: .deletedTaskTypeListIsRequired)
    let deletedTaskListIsRequired = SettingsItem(imageName: "trash", text: "Задачи", type: .deletedTaskListIsRequired)
    // security
    let removeAccount = SettingsItem(imageName: "remove", text: "Удалить аккаунт", type: .removeAccountIsRequired)
    // help
    let askSupport = SettingsItem(imageName: "message-notif", text: "Обратиться в поддержку", type: .askSupport)
    
    // dataSource
    let dataSource = currentUser
      .map {[
        SettingsCellSectionModel(
          header: "Аккаунт",
          items: [$0 == nil ? logInIsRequired : userProfileIsRequired]),
        SettingsCellSectionModel(
          header: "Облако",
          items: [saveDataIsRequired, loadDataIsRequired]),
        SettingsCellSectionModel(
          header: "Удаленные данные",
          items: [deletedTaskTypeListIsRequired, deletedTaskListIsRequired]),
        SettingsCellSectionModel(
          header: "Поддержка",
          items: [askSupport]),
        SettingsCellSectionModel(
          header: "Безопасность",
          items: [removeAccount])
      ]}

    
    let itemSelected = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource in
        let item = dataSource[indexPath.section].items[indexPath.item]
        switch item.type {
        case .deletedTaskListIsRequired:
          self.steps.accept(AppStep.DeletedTaskListIsRequired)
        case .deletedTaskTypeListIsRequired:
          self.steps.accept(AppStep.DeletedTaskTypeListIsRequired)
        case .logInIsRequired:
          self.steps.accept(AppStep.AuthIsRequired)
        case .userProfileIsRequiared:
          self.steps.accept(AppStep.UserProfileIsRequired)
        default:
          return
        }
      }
    
    let backButtonClick = input.backButtonClickTrigger
      .map { self.steps.accept(AppStep.NavigateBack) }
    
    return Output(
      backButtonClick: backButtonClick,
      itemSelected: itemSelected,
      dataSource: dataSource
    )
  }
  
  func setOnboardedNotCompleted() {
    UserDefaults.standard.set(false, forKey: "isOnboardingCompleted")
  }
}
