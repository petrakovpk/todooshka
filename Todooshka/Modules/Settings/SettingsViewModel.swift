//
//  SettingsViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 14.06.2021.
//

import CoreData
import Firebase
import RxFlow
import RxSwift
import RxCocoa
import UIKit

class SettingsViewModel: Stepper {
  
  let services: AppServices
  let steps = PublishRelay<Step>()
  
  private let dataSource = BehaviorRelay<[SettingsCellSectionModel]>(value: [])
  private let showAlert = BehaviorRelay<Bool>(value: false)
  
  // auth
  let logInIsRequired = SettingsItem(imageName: "login", text: "Войти в аккаунт", type: .LogInIsRequired)
  //data
  let syncDataIsRequired = SettingsItem(imageName: "box-tick", text: "Синхронизировать данные", type: .SyncDataIsRequired)
  // deleted
  let deletedTaskTypeListIsRequired = SettingsItem(imageName: "trash", text: "Типы", type: .DeletedTaskTypeListIsRequired)
  let deletedTaskListIsRequired = SettingsItem(imageName: "trash", text: "Задачи", type: .DeletedTaskListIsRequired)
  // security
 // let removeAccount = SettingsItem(imageName: "remove", text: "Удалить аккаунт", type: .DeleteAccountIsRequired)
  // help
  let askSupport = SettingsItem(imageName: "message-notif", text: "Обратиться в поддержку", type: .SupportIsRequired)
  
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
    
    let currentUser = Auth.auth().rx.stateDidChange
      .asDriver(onErrorJustReturn: nil)
    
    let userName = currentUser
      .compactMap{ $0 }
      .asObservable()
      .flatMapLatest({ DB_USERS_REF.child($0.uid).child("PERSONAL").rx.observeEvent(.value) })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
      .compactMap { result -> DataSnapshot? in
        guard case .success(let dataSnapshot) = result else { return nil }
        return dataSnapshot
      }
      .map { snapshot -> NSDictionary? in
        snapshot.value as? NSDictionary
      }
      .map { dict -> String? in
        dict?.value(forKey: "name") as? String
      }.withLatestFrom(currentUser) { name, currentUser -> String in
        name ?? (currentUser?.displayName ?? "Главный герой")
      }
    
    
    let userProfileIsRequired = userName
      .startWith("")
      .map {
        SettingsItem(
          imageName: "user-square",
          text: $0,
          type: .UserProfileIsRequiared
        )
      }

    // dataSource
    let dataSource = Driver
      .combineLatest(currentUser, userProfileIsRequired) { currentUser, userProfileIsRequired in
        [
          SettingsCellSectionModel(
            header: "Аккаунт",
            items: [currentUser == nil ? self.logInIsRequired : userProfileIsRequired]),
          SettingsCellSectionModel(
            header: "Облако",
            items: [self.syncDataIsRequired]),
          SettingsCellSectionModel(
            header: "Удаленные данные",
            items: [self.deletedTaskTypeListIsRequired, self.deletedTaskListIsRequired]),
          SettingsCellSectionModel(
            header: "Поддержка",
            items: [self.askSupport])
        ]
      }
    
    let itemSelected = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource in
        let item = dataSource[indexPath.section].items[indexPath.item]
        switch item.type {
        case .DeletedTaskListIsRequired:
          self.steps.accept(AppStep.DeletedTaskListIsRequired)
        case .DeletedTaskTypeListIsRequired:
          self.steps.accept(AppStep.DeletedTaskTypeListIsRequired)
        case .LogInIsRequired:
          self.steps.accept(AppStep.AuthIsRequired)
        case .UserProfileIsRequiared:
          self.steps.accept(AppStep.UserProfileIsRequired)
        case .SyncDataIsRequired:
          self.steps.accept(AppStep.SyncDataIsRequired)
        case .SupportIsRequired:
          self.steps.accept(AppStep.SupportIsRequired)
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
