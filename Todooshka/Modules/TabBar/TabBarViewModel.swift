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
  var selectedItem: Int = 1

  struct Input {
    let createTaskButtonClickTrigger: Driver<Void>
  }

  struct Output {
    let createTask: Driver<Void>
   // let firebaseKindsOfTask: Driver<[KindOfTask]>
  }

  init(services: AppServices) {
    self.services = services
  }

  func selectedItem(item: UITabBarItem) {
    if item.tag == 2 {
      services.preferencesService.scrollToCurrentMonthTrigger.accept((true, selectedItem == 2 ? true : false ))
      selectedItem = item.tag
    }
  }

  func transform(input: Input) -> Output {

    services.tabBarService.selectedItem.accept(selectedItem == 1 ? .left : .right)

    let createTask = input.createTaskButtonClickTrigger
      .map { self.steps.accept(AppStep.createTaskIsRequired) }

    return Output(
      createTask: createTask
    )
  }

}
