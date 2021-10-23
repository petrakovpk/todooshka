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
    let showDeletedTaskTypesItem = SettingsItem(imageName: "trash", text: "Удаленные типы", type: .deletedTaskTypeListIsRequired)
    let showDeletedTasksItem = SettingsItem(imageName: "trash", text: "Удаленные задачи", type: .deletedTaskListIsRequired)
    
    let dataSource = Driver.just([UserProfileSettingsSectionModel(header: "Удаленные данные", items: [showDeletedTaskTypesItem, showDeletedTasksItem])])
    
    let itemSelected = input.selection.withLatestFrom(dataSource) { indexPath, dataSource in
      let item = dataSource[indexPath.section].items[indexPath.item]
      switch item.type {
      case .deletedTaskListIsRequired:
        self.steps.accept(AppStep.deletedTaskListIsRequired)
      case .deletedTaskTypeListIsRequired:
        self.steps.accept(AppStep.deletedTaskTypeListIsRequired)
      default:
        return
      }
    }
    
    let backButtonClick = input.backButtonClickTrigger.map { self.steps.accept(AppStep.userSettingsIsCompleted) }
    
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
