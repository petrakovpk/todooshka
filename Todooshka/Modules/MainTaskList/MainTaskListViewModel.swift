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
  }

  struct Output {
    let openOverduedTasklist: Driver<Void>
    let openIdeaTaskList: Driver<Void>
    let openCalendar: Driver<Void>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {
    // overdued
    let openOverduedTasklist = input.overduedButtonClickTrigger
      .do { _ in self.steps.accept(AppStep.overduedTaskListIsRequired) }
    
    // idea
    let openIdeaTaskList = input.ideaButtonClickTrigger
      .do { _ in self.steps.accept(AppStep.ideaTaskListIsRequired) }
    
    // calendar
    let openCalendar = input.calendarButtonClickTrigger
     

    return Output(
      openOverduedTasklist: openOverduedTasklist,
      openIdeaTaskList: openIdeaTaskList,
      openCalendar: openCalendar
    )
  }
}
