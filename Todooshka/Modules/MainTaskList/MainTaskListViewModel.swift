//
//  MainTaskListViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 05.04.2022.
//

import CoreData
import RxFlow
import RxSwift
import RxCocoa
import UIKit

class MainTaskListViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  public let swipeDeleteButtonClickTrigger = PublishRelay<IndexPath>()
  public let swipeIdeaButtonClickTrigger = PublishRelay<IndexPath>()

  private let services: AppServices
  private let disposeBag = DisposeBag()

  struct Input {
    // overdued
    let overduedButtonClickTrigger: Driver<Void>
    // idea
    let ideaButtonClickTrigger: Driver<Void>
    // task list
    let taskSelected: Driver<IndexPath>
    // alert
    let alertDeleteButtonClick: Driver<Void>
    let alertCancelButtonClick: Driver<Void>
  }

  struct Output {
    // overdued
    let overduredTaskListOpen: Driver<Void>
    // idea
    let ideaTaskListOpen: Driver<Void>
    // task sections
    let taskListSections: Driver<[TaskListSection]>
    let taskListOpenTask: Driver<AppStep>
    // alert
    let deleteAlertIsHidden: Driver<Bool>
    // save task
    let saveTask: Driver<Void>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {
    let kinds = services.currentUserService.currentUserKinds
    let tasks = services.currentUserService.currentUserTasks
    let swipeIdeaButtonClickTrigger = swipeIdeaButtonClickTrigger.asDriverOnErrorJustComplete()
    let swipeDeleteButtonClickTrigger = swipeDeleteButtonClickTrigger.asDriverOnErrorJustComplete()
    
    let allDayItems = Driver
      .combineLatest(kinds, tasks) { kinds, tasks -> [TaskListSectionItem] in
        tasks.filter { task -> Bool in
          task.status == .inProgress &&
          task.planned.roundToTheBottomMinute == Date().endOfDay.roundToTheBottomMinute
        }
        .map { task -> TaskListSectionItem in
          TaskListSectionItem(
            task: task,
            kind: kinds.first { $0.uuid == task.kindUUID },
            mode: .blueLine
          )
        }
    }
    
    let inDayItems = Driver
      .combineLatest(kinds, tasks) { kinds, tasks -> [TaskListSectionItem] in
        tasks.filter { task -> Bool in
          task.status == .inProgress &&
          task.planned >= Date().startOfDay &&
          task.planned.roundToTheBottomMinute < Date().endOfDay.roundToTheBottomMinute
        }
        .map { task -> TaskListSectionItem in
          TaskListSectionItem(
            task: task,
            kind: kinds.first { $0.uuid == task.kindUUID },
            mode: .redLineAndTime
          )
        }
    }
    
    let taskListSections = Driver
      .combineLatest(allDayItems, inDayItems) { allDayItems, inDayItems -> [TaskListSection] in
        [
          TaskListSection(header: "В течении дня:", items: allDayItems),
          TaskListSection(header: "Внимание, время:", items: inDayItems)
        ]
          .filter { !$0.items.isEmpty }
      }
    
    let overduredTaskListOpen = input.overduedButtonClickTrigger
      .map { _ in AppStep.overduedTaskListIsRequired }
      .do { step in self.steps.accept(step) }
      .mapToVoid()
    
    let ideaTaskListOpen = input.ideaButtonClickTrigger
      .map { _ in AppStep.ideaTaskListIsRequired }
      .do { step in self.steps.accept(step) }
      .mapToVoid()
    
    let taskListOpenTask = input.taskSelected
      .withLatestFrom(taskListSections) { indexPath, sections -> TaskListSectionItem in
        sections[indexPath.section].items[indexPath.item]
      }
      .map { item -> AppStep in
        AppStep.openTaskIsRequired(task: item.task, taskListMode: .main)
      }
      .do { step in
        self.steps.accept(step)
      }
    
    let swipeDeleteButtonItem = swipeDeleteButtonClickTrigger
      .withLatestFrom(taskListSections) { indexPath, sections -> TaskListSectionItem in
        sections[indexPath.section].items[indexPath.item]
      }
    
    let swipeIdeaButtonItem = swipeIdeaButtonClickTrigger
      .withLatestFrom(taskListSections) { indexPath, sections -> TaskListSectionItem in
        sections[indexPath.section].items[indexPath.item]
      }
    
    let showDeleteAlert = swipeDeleteButtonItem.mapToVoid()
    
    let hideDeleteAlert = Driver
      .of(input.alertDeleteButtonClick, input.alertCancelButtonClick)
      .merge()
    
    let deleteAlertIsHidden = Driver.of(
      showDeleteAlert.map { _ in false },
      hideDeleteAlert.map { _ in true }
    )
      .merge()
    
    let taskChangeStatusToDeleted = input.alertDeleteButtonClick
      .withLatestFrom(swipeDeleteButtonItem)
      .map { item -> Task in
        var task = item.task
        task.status = .deleted
        return task
      }
    
    let taskChangeStatusToIdea = swipeIdeaButtonItem
      .map { item -> Task in
        var task = item.task
        task.status = .idea
        return task
      }
    
    let saveTask = Driver
      .of(taskChangeStatusToDeleted, taskChangeStatusToIdea)
      .merge()
      .asObservable()
      .flatMapLatest { task -> Observable<Void> in
        return task.updateToStorage()
      }
      .asDriver(onErrorJustReturn: ())
    
//    // MARK: - INIT
//    let tasks = services.dataService.tasks
//    let kindsOfTask = services.dataService.kindsOfTask

//
//    // MARK: - NAVIGATE
//    let openOverduedTaskList = input.overduedButtonClickTrigger
//      .do { _ in self.steps.accept(AppStep.overduedTaskListIsRequired) }
//
//    let openIdeaTaskList = input.ideaButtonClickTrigger
//      .do { _ in self.steps.accept(AppStep.ideaTaskListIsRequired) }
//
//    // MARK: - DATASOURCE
//    let dataSource = Driver
//      .combineLatest(tasks, kindsOfTask) { tasks, kindsOfTask -> [TaskListSectionItem] in
//        tasks
//          .filter { task -> Bool in
//            task.status == .inProgress &&
//            task.planned.startOfDay >= Date().startOfDay &&
//            task.planned.endOfDay <= Date().endOfDay
//          }
//          .map { task -> TaskListSectionItem in
//            TaskListSectionItem(
//              task: task,
//              kindOfTask: kindsOfTask.first { $0.UID == task.kindOfTaskUID } ?? KindOfTask.Standart.Simple
//            )
//          }
//          .sorted { prevItem, nextItem -> Bool in
//            (prevItem.task.planned == nextItem.task.planned) ? (prevItem.task.created < nextItem.task.created) : (prevItem.task.planned < nextItem.task.planned)
//          }
//      }
//      .map { items -> [TaskListSection] in
//        [
//          TaskListSection(
//            header: "Внимание, время:",
//            mode: .redLineAndTime,
//            items: items.filter { item -> Bool in
//                item.task.planned.roundToTheBottomMinute != Date().endOfDay.roundToTheBottomMinute
//              }
//          ),
//          TaskListSection(
//            header: "В течении дня:",
//            mode: .blueLine,
//            items: items.filter { item -> Bool in
//              item.task.planned.roundToTheBottomMinute == Date().endOfDay.roundToTheBottomMinute
//            }
//          )
//        ]
//      }
//      .map {
//        $0.filter { !$0.items.isEmpty }
//      }
//
//    let timer = Observable<Int>
//      .timer(.seconds(0), period: .seconds(60), scheduler: MainScheduler.instance)
//      .asDriver(onErrorJustReturn: 0)
//
//    let reloadItems = timer
//      .withLatestFrom(dataSource) { _, dataSource -> [IndexPath] in
//        dataSource.enumerated().flatMap { sectionIndex, section -> [IndexPath] in
//          section.items.enumerated().compactMap { itemIndex, item -> IndexPath? in
//            (IndexPath(item: itemIndex, section: sectionIndex) == self.editingIndexPath) ? nil : IndexPath(item: itemIndex, section: sectionIndex)
//          }
//        }
//      }
//
//    let openTask = input.selection
//      .withLatestFrom(dataSource) { indexPath, dataSource -> Task in
//        dataSource[indexPath.section].items[indexPath.item].task
//      }
//      .map { self.steps.accept(AppStep.showTaskIsRequired(task: $0 )) }
//
//
//    let changeTaskStatusToIdea = swipeIdeaButtonClickTrigger
//      .withLatestFrom(dataSource) { indexPath, dataSource -> Task in
//        dataSource[indexPath.section].items[indexPath.item].task
//      }
//      .change(status: .idea)
//      .asObservable()
//      .flatMapLatest { self.managedContext.rx.update($0) }
//      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))
//
//    let taskForRemoving = swipeDeleteButtonClickTrigger
//      .withLatestFrom(dataSource) { indexPath, dataSource -> Task in
//        dataSource[indexPath.section].items[indexPath.item].task
//      }
//
//    let showAlertTriger = taskForRemoving
//      .map { _ in false }
//
//    let hideAlertTrigger = Driver
//      .of(input.alertCancelButtonClick, input.alertDeleteButtonClick)
//      .merge()
//      .map { _ in true  }
//
//    let alertIsHidden = Driver
//      .of(showAlertTriger, hideAlertTrigger)
//      .merge()
//
//    let hideCellWhenAlertClosed = hideAlertTrigger
//      .withLatestFrom(swipeDeleteButtonClickTrigger)
//
//    let changeTaskStatusToDeleted = input.alertDeleteButtonClick
//      .withLatestFrom(taskForRemoving)
//      .change(status: .deleted)
//      .asObservable()
//      .flatMapLatest { self.managedContext.rx.update($0) }
//      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))
                      
    return Output(
      // overdued
      overduredTaskListOpen: overduredTaskListOpen,
      // idea
      ideaTaskListOpen: ideaTaskListOpen,
      // task list
      taskListSections: taskListSections,
      taskListOpenTask: taskListOpenTask,
      // alert
      deleteAlertIsHidden: deleteAlertIsHidden,
      // save task
      saveTask: saveTask
//      reloadItems: reloadItems,
//      hideCellWhenAlertClosed: hideCellWhenAlertClosed,
//      openTask: openTask,
//      changeTaskStatusToIdea: changeTaskStatusToIdea,
//      changeTaskStatusToDeleted: changeTaskStatusToDeleted,
//      alertIsHidden: alertIsHidden
    )
  }
}
