//
//  MainTaskListViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 05.04.2022.
//

import RxFlow
import RxSwift
import RxCocoa
import UIKit

class MainTaskListViewModel: Stepper {
  // MARK: - Properties
  let steps = PublishRelay<Step>()
  let services: AppServices
  let disposeBag = DisposeBag()

  struct Input {
    // OVERDUED
    let overduedButtonClickTrigger: Driver<Void>
    // IDEA
    let ideaButtonClickTrigger: Driver<Void>
    // CALENDAR
    let calendarButtonClickTrigger: Driver<Void>
    // TASK LIST
    let taskListButtonClickTrigger: Driver<Void>
    // SHOP
    let shopButtoClickTrigger: Driver<Void>
  }

  struct Output {
    // BUTTONS
    let openOverduedTasklist: Driver<Void>
    let openIdeaTaskList: Driver<Void>
    let openCalendar: Driver<Void>
    let openTaskList: Driver<Void>
    let openShop: Driver<Void>
    // DATASOURCE
    let calendarDataSource: Driver<[CalendarSection]>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {
    // MARK: - BUTTONS
    let openOverduedTasklist = input.overduedButtonClickTrigger
      .do { _ in self.steps.accept(AppStep.overduedTaskListIsRequired) }
    
    let openIdeaTaskList = input.ideaButtonClickTrigger
      .do { _ in self.steps.accept(AppStep.ideaTaskListIsRequired) }
    
    let openCalendar = input.calendarButtonClickTrigger
     
    let openTaskList = input.taskListButtonClickTrigger
    
    let openShop = input.shopButtoClickTrigger
      .do { _ in self.steps.accept(AppStep.shopIsRequired) }
    
    // MARK: - DATASOURCE
    let calendarDataSource = Driver<[CalendarSection]>.of([])

    return Output(
      openOverduedTasklist: openOverduedTasklist,
      openIdeaTaskList: openIdeaTaskList,
      openCalendar: openCalendar,
      openTaskList: openTaskList,
      openShop: openShop,
      calendarDataSource: calendarDataSource
    )
  }
}
