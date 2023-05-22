//
//  UserProfileTaskListViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 01.05.2023.
//

import RxFlow
import RxSwift
import RxCocoa

class UserProfileTaskListViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  
  private let services: AppServices
  
  struct Input {
    let selection: Driver<IndexPath>
  }
  
  struct Output {
    let taskListSections: Driver<[TaskListSection]>
    let openTask: Driver<AppStep>
  }


  
  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {
    let kinds = services.currentUserService.kinds
    let tasks = services.currentUserService.tasks
    
    // MARK: - Datasource - Completed
    let completedTaskListItems = Driver
      .combineLatest(kinds, tasks) { kinds, tasks -> [TaskListSectionItem] in
        tasks.filter { task -> Bool in
          task.status == .completed
        }
        .map { task -> TaskListSectionItem in
          TaskListSectionItem(
            task: task,
            kind: kinds.first { $0.uuid == task.kindUUID },
            mode: .empty)
        }
      }
    
    let completedTaskListSection = completedTaskListItems
      .map { items -> [TaskListSection] in
        Dictionary(grouping: items) { $0.task.completed?.startOfDay }
          .map { (date, items) -> TaskListSection in
            TaskListSection(header: date?.string(withFormat: "d MMM yyyy") ?? "", items: items)
          }
      }
    
  
    let openTask = input.selection
      .withLatestFrom(completedTaskListSection) { indexPath, sections -> Task in
        sections[indexPath.section].items[indexPath.item].task
      }
      .map { task -> AppStep in
        AppStep.openTaskIsRequired(task: task, taskListMode: .userProfile)
      }
      .do { step in
        self.steps.accept(step)
      }
    
    return Output(
      taskListSections: completedTaskListSection,
      openTask: openTask
    )
  }
}
