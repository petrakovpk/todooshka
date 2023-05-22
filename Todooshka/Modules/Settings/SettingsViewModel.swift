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
  public let steps = PublishRelay<Step>()
  
  private let services: AppServices
  

  private let dataSource = BehaviorRelay<[SettingSection]>(value: [])
  private let showAlert = BehaviorRelay<Bool>(value: false)

  struct Input {
    // header
    let backButtonClickTrigger: Driver<Void>
    // table view
    let settingIsSelected: Driver<IndexPath>
  }

  struct Output {
    // header
    let navigateBack: Driver<AppStep>
    // table
    let settingsSections: Driver<[SettingSection]>
    // settings
    let openTheSetting: Driver<AppStep>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {
    let currentUser = services.currentUserService.user
    
    let accountItems = currentUser
      .flatMapLatest { user -> Driver<[SettingItem]> in
        if let user = user {
          return Driver.just([SettingItem(text: "Потом загрузить", type: .openProfileIsRequired) ])
        } else {
          return Driver.just([SettingItem(text: "Войти в аккаунт", type: .authIsRequired)])
        }
      }
     
    let accountSection = accountItems
      .map { items -> SettingSection in
        SettingSection(header: "Аккаунт", items: items)
      }
    
    let deletedItems = Driver<[SettingItem]>.of([
      SettingItem(text: "Типы", type: .deletedKindListIsRequired),
      SettingItem(text: "Задачи", type: .deletedTaskListIsRequired)
    ])
      .asDriver(onErrorJustReturn: [])
    
    let deletedSection = deletedItems
      .map { items -> SettingSection in
        SettingSection(header: "Удаленные данные", items: items)
      }
    
    let supportItems = Driver<[SettingItem]>.of([
      SettingItem(text: "Обратиться в поддержку", type: .supportIsRequired)
    ])
      .asDriver(onErrorJustReturn: [])

    let supportSection = supportItems
      .map { items -> SettingSection in
        SettingSection(header: "Поддержка", items: items)
      }
    
    let settingsSections = Driver<[SettingSection]>
      .combineLatest(accountSection, deletedSection, supportSection) { accountSection, deletedSection, supportSection -> [SettingSection] in
        [accountSection, deletedSection, supportSection]
      }
    
    let openTheSetting = input.settingIsSelected
      .withLatestFrom(settingsSections) { indexPath, sections -> SettingItem in
        sections[indexPath.section].items[indexPath.item]
      }
      .compactMap { item -> AppStep? in
        switch item.type {
        case .authIsRequired:
          return AppStep.authIsRequired
        case .openProfileIsRequired:
          return AppStep.accountSettingsIsRequired
        case .deletedKindListIsRequired:
          return AppStep.deletedKindListIsRequired
        case .deletedTaskListIsRequired:
          return AppStep.deletedTaskListIsRequired
        case .supportIsRequired:
          return AppStep.supportIsRequired
        default:
          return nil
        }
      }
      .do { step in
        self.steps.accept(step)
      }
    
    let navigateBack = input.backButtonClickTrigger
      .map { _ in AppStep.navigateBack }
      .do { step in
        self.steps.accept(step)
      }

    return Output(
      // header
      navigateBack: navigateBack,
      // table
      settingsSections: settingsSections,
      // settings
      openTheSetting: openTheSetting
    )
  }

  func setOnboardedNotCompleted() {
    UserDefaults.standard.set(false, forKey: "isOnboardingCompleted")
  }
}
