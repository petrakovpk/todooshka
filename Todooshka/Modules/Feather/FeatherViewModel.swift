//
//  FeatherViewModel.swift
//  Todooshka
//
//  Created by Pavel Petakov on 20.06.2022.
//

import RxFlow
import RxSwift
import RxCocoa

class FeatherViewModel: Stepper {
  // MARK: - Properties
  let steps = PublishRelay<Step>()
  let services: AppServices

  // MARK: - Transform
  struct Input {
    let backButtonClickTrigger: Driver<Void>
  }

  struct Output {
    let dataSource: Driver<[TaskListSection]>
    let navigateBack: Driver<Void>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  // MARK: - Transform
  func transform(input: Input) -> Output {
    // tasks
    let tasks = services.dataService.goldTasks

    let kindsOfTask = services.dataService.kindsOfTask.asDriver()

    let taskListSectionItems = Driver<[TaskListSectionItem]>
      .combineLatest(tasks, kindsOfTask) { tasks, kindsOfTask -> [TaskListSectionItem] in
        tasks.map { task in
          TaskListSectionItem(
            task: task,
            kindOfTask: kindsOfTask.first(where: { $0.UID == task.kindOfTaskUID }) ?? KindOfTask.Standart.Simple
          )
        }
      }

    // dataSource
    let dataSource = taskListSectionItems
      .map {
        Dictionary
          .init(grouping: $0, by: { $0.task.closed!.startOfDay })
          .sorted(by: { $0.key > $1.key })
          .map { key, value in
            TaskListSection(header: self.services.preferencesService.formatter.string(from: key), mode: .withFeather, items: value)
          }
      }

    // backButtonClickHandler
    let navigateBack = input.backButtonClickTrigger
      .map { self.steps.accept(AppStep.navigateBack) }

    return Output(
      dataSource: dataSource,
      navigateBack: navigateBack
    )
  }
}
