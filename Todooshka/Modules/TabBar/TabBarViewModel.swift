//
//  TabBarViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 28.07.2021.
//

import RxFlow
import RxSwift
import RxCocoa

class TabBarViewModel: Stepper {
  let steps = PublishRelay<Step>()
  let services: AppServices

  struct Input {
    let createTaskButtonClickTrigger: Driver<Void>
  }

  struct Output {
    let createTask: Driver<Void>
  }

  init(services: AppServices) {
    self.services = services
  }

//  func selectedItem(item: UITabBarItem) {
//    switch item.tag {
//    case 1:
//      services.tabBarService.selectedItem.accept(.fun)
//    case 2:
//      services.tabBarService.selectedItem.accept(.taskList)
//    case 3:
//      if services.tabBarService.selectedItem.value == .userProfile {
//       // services.preferencesService.scrollToCurrentMonthTrigger.accept((true, true))
//      }
//      services.tabBarService.selectedItem.accept(.userProfile)
//    default:
//      return
//    }
//  }

  func transform(input: Input) -> Output {
    let createTask = input.createTaskButtonClickTrigger
      .do { _ in
        self.steps.accept(
          AppStep.createTaskIsRequired(
            task: Task(UID: UUID().uuidString, status: .inProgress),
            isModal: true
          ))
      }

    return Output(
      createTask: createTask
    )
  }
}
