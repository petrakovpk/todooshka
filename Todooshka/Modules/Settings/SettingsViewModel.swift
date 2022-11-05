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
  let logInIsRequired = SettingsItem(imageName: "login", text: "Войти в аккаунт", type: .logInIsRequired)
  // data
  let syncDataIsRequired = SettingsItem(imageName: "box-tick", text: "Синхронизировать данные", type: .syncDataIsRequired)
  // deleted
  let deletedTaskTypeListIsRequired = SettingsItem(imageName: "trash", text: "Типы", type: .deletedTaskTypeListIsRequired)
  let deletedTaskListIsRequired = SettingsItem(imageName: "trash", text: "Задачи", type: .deletedTaskListIsRequired)
  // help
  let askSupport = SettingsItem(imageName: "message-notif", text: "Обратиться в поддержку", type: .supportIsRequired)

  struct Input {
    let backButtonClickTrigger: Driver<Void>
    let selection: Driver<IndexPath>
  }

  struct Output {
    let backButtonClick: Driver<Void>
    let itemSelected: Driver<Void>
    let dataSource: Driver<[SettingsCellSectionModel]>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {

    let currentUser = Auth.auth().rx.stateDidChange
      .asDriver(onErrorJustReturn: nil)

    let userName = currentUser
      .compactMap { $0 }
      .asObservable()
      .flatMapLatest({ dbUserRef.child($0.uid).child("PERSONAL").rx.observeEvent(.value) })
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))
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
          type: .userProfileIsRequiared
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
        case .deletedTaskListIsRequired:
          self.steps.accept(AppStep.deletedTaskListIsRequired)
        case .deletedTaskTypeListIsRequired:
          self.steps.accept(AppStep.deletedTaskTypeListIsRequired)
        case .logInIsRequired:
          self.steps.accept(AppStep.authIsRequired)
        case .userProfileIsRequiared:
          self.steps.accept(AppStep.userProfileIsRequired)
        case .syncDataIsRequired:
          self.steps.accept(AppStep.syncDataIsRequired)
        case .supportIsRequired:
          self.steps.accept(AppStep.supportIsRequired)
        }
      }

    let backButtonClick = input.backButtonClickTrigger
      .map { self.steps.accept(AppStep.navigateBack) }

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
