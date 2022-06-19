//
//  UserProfileSettingsViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 14.06.2021.
//


import RxFlow
import RxSwift
import RxCocoa
import UIKit
import CoreData


class UserProfileSettingsViewModel: Stepper {
  
  let steps = PublishRelay<Step>()
  let dataSource = BehaviorRelay<[UserProfileSettingsSectionModel]>(value: [])
  
  public let services: AppServices
  private let disposeBag = DisposeBag()
  let showAlert = BehaviorRelay<Bool>(value: false)
  
  struct Input {
    let backButtonClickTrigger: Driver<Void>
    let selection: Driver<IndexPath>
    
  }
  
  struct Output {
    let backButtonClick: Driver<Void>
    let itemSelected: Driver<Void>
    let dataSource: Driver<[UserProfileSettingsSectionModel]>
  }
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  func transform(input: Input) -> Output {
    
    // auth
    let logInIsRequired = SettingsItem(imageName: "login", text: "Войти в аккаунт", type: .logInIsRequired)
    let logOutIsRequired = SettingsItem(imageName: "logout", text: "Выйти из аккаунта", type: .logOutIsRequired)

    //data
    let saveDataIsRequired = SettingsItem(imageName: "box-add", text: "Сохранить данные", type: .saveDataIsRequired)
    let loadDataIsRequired = SettingsItem(imageName: "box-tick", text: "Загрузить данные", type: .loadDataIsRequired)
    
    // deleted
    let deletedTaskTypeListIsRequired = SettingsItem(imageName: "trash", text: "Типы", type: .deletedTaskTypeListIsRequired)
    let deletedTaskListIsRequired = SettingsItem(imageName: "trash", text: "Задачи", type: .deletedTaskListIsRequired)
    
    // security
    let removeAccount = SettingsItem(imageName: "remove", text: "Удалить аккаунт", type: .removeAccountIsRequired)
    
    // dataSource
    let dataSource = Driver.just([
      UserProfileSettingsSectionModel(
        header: "Аккаунт",
        items: [logInIsRequired, logOutIsRequired]),
      UserProfileSettingsSectionModel(
        header: "Облако",
        items: [saveDataIsRequired, loadDataIsRequired]),
      UserProfileSettingsSectionModel(
        header: "Удаленные данные",
        items: [deletedTaskTypeListIsRequired, deletedTaskListIsRequired]),
      UserProfileSettingsSectionModel(
        header: "Безопасность",
        items: [removeAccount])
      
    ])
    
    let itemSelected = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource in
        let item = dataSource[indexPath.section].items[indexPath.item]
        switch item.type {
        case .deletedTaskListIsRequired:
          self.steps.accept(AppStep.DeletedTaskListIsRequired)
        case .deletedTaskTypeListIsRequired:
          self.steps.accept(AppStep.DeletedTaskTypeListIsRequired)
        default:
          return
        }
      }
    
    let backButtonClick = input.backButtonClickTrigger.map { self.steps.accept(AppStep.UserSettingsIsCompleted) }
    
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
