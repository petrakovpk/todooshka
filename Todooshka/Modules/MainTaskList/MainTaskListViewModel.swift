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
  
  public var editingIndexPath: IndexPath?
  
  private let services: AppServices
  private let disposeBag = DisposeBag()
  private let appDelegate = UIApplication.shared.delegate as! AppDelegate
  
  private var managedContext: NSManagedObjectContext { appDelegate.persistentContainer.viewContext }


  struct Input {
    let overduedButtonClickTrigger: Driver<Void>
    let ideaButtonClickTrigger: Driver<Void>
    let calendarButtonClickTrigger: Driver<Void>
    let selection: Driver<IndexPath>
    let alertDeleteButtonClick: Driver<Void>
    let alertCancelButtonClick: Driver<Void>
  }

  struct Output {
    // BUTTONS
    let openOverduedTasklist: Driver<Void>
    let openIdeaTaskList: Driver<Void>
    let openCalendar: Driver<Void>
    // COLLECTION VIEW
    let dataSource: Driver<[TaskListSection]>
    let reloadItems: Driver<[IndexPath]>
    let hideCellWhenAlertClosed: Driver<IndexPath>
    // TASK
    let openTask: Driver<Void>
    let changeTaskStatusToIdea: Driver<Result<Void, Error>>
    let changeTaskStatusToDeleted: Driver<Result<Void, Error>>
    // ALERT
    let alertIsHidden: Driver<Bool>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {
    // MARK: - INIT
    let tasks = services.dataService.tasks
    let kindsOfTask = services.dataService.kindsOfTask
    let swipeIdeaButtonClickTrigger = swipeIdeaButtonClickTrigger.asDriverOnErrorJustComplete()
    let swipeDeleteButtonClickTrigger = swipeDeleteButtonClickTrigger.asDriverOnErrorJustComplete()
    
    // MARK: - NAVIGATE
    let openOverduedTaskList = input.overduedButtonClickTrigger
      .do { _ in self.steps.accept(AppStep.overduedTaskListIsRequired) }
    
    let openIdeaTaskList = input.ideaButtonClickTrigger
      .do { _ in self.steps.accept(AppStep.ideaTaskListIsRequired) }
    
    let openCalendar = input.calendarButtonClickTrigger
      .do { _ in
        self.services.preferencesService.workplaceScrollToPageIndex.accept(1)
      }

    // MARK: - DATASOURCE
    let dataSource = Driver
      .combineLatest(tasks, kindsOfTask) { tasks, kindsOfTask -> [TaskListSectionItem] in
        tasks
          .filter { task -> Bool in
            task.status == .inProgress &&
            task.planned.startOfDay >= Date().startOfDay &&
            task.planned.endOfDay <= Date().endOfDay
          }
          .map { task -> TaskListSectionItem in
            TaskListSectionItem(
              task: task,
              kindOfTask: kindsOfTask.first { $0.UID == task.kindOfTaskUID } ?? KindOfTask.Standart.Simple
            )
          }
          .sorted { prevItem, nextItem -> Bool in
            (prevItem.task.planned == nextItem.task.planned) ? (prevItem.task.created < nextItem.task.created) : (prevItem.task.planned < nextItem.task.planned)
          }
      }
      .map { items -> [TaskListSection] in
        [
          TaskListSection(
            header: "Внимание, время:",
            mode: .redLineAndTime,
            items: items.filter { item -> Bool in
                item.task.planned.roundToTheBottomMinute != Date().endOfDay.roundToTheBottomMinute
              }
          ),
          TaskListSection(
            header: "В течении дня:",
            mode: .blueLine,
            items: items.filter { item -> Bool in
              item.task.planned.roundToTheBottomMinute == Date().endOfDay.roundToTheBottomMinute
            }
          )
        ]
      }
      .map {
        $0.filter { !$0.items.isEmpty }
      }
    
    let timer = Observable<Int>
      .timer(.seconds(0), period: .seconds(60), scheduler: MainScheduler.instance)
      .asDriver(onErrorJustReturn: 0)

    let reloadItems = timer
      .withLatestFrom(dataSource) { _, dataSource -> [IndexPath] in
        dataSource.enumerated().flatMap { sectionIndex, section -> [IndexPath] in
          section.items.enumerated().compactMap { itemIndex, item -> IndexPath? in
            (IndexPath(item: itemIndex, section: sectionIndex) == self.editingIndexPath) ? nil : IndexPath(item: itemIndex, section: sectionIndex)
          }
        }
      }
    
    let openTask = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource -> Task in
        dataSource[indexPath.section].items[indexPath.item].task
      }
      .map { self.steps.accept(AppStep.showTaskIsRequired(task: $0 )) }
  
    
    let changeTaskStatusToIdea = swipeIdeaButtonClickTrigger
      .withLatestFrom(dataSource) { indexPath, dataSource -> Task in
        dataSource[indexPath.section].items[indexPath.item].task
      }
      .change(status: .idea)
      .asObservable()
      .flatMapLatest { self.managedContext.rx.update($0) }
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))
    
    let taskForRemoving = swipeDeleteButtonClickTrigger
      .withLatestFrom(dataSource) { indexPath, dataSource -> Task in
        dataSource[indexPath.section].items[indexPath.item].task
      }

    let showAlertTriger = taskForRemoving
      .map { _ in false }
    
    let hideAlertTrigger = Driver
      .of(input.alertCancelButtonClick, input.alertDeleteButtonClick)
      .merge()
      .map { _ in true  }
    
    let alertIsHidden = Driver
      .of(showAlertTriger, hideAlertTrigger)
      .merge()
    
    let hideCellWhenAlertClosed = hideAlertTrigger
      .withLatestFrom(swipeDeleteButtonClickTrigger)
    
    let changeTaskStatusToDeleted = input.alertDeleteButtonClick
      .withLatestFrom(taskForRemoving)
      .change(status: .deleted)
      .asObservable()
      .flatMapLatest { self.managedContext.rx.update($0) }
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))
                      
                      

    return Output(
      openOverduedTasklist: openOverduedTaskList,
      openIdeaTaskList: openIdeaTaskList,
      openCalendar: openCalendar,
      dataSource: dataSource,
      reloadItems: reloadItems,
      hideCellWhenAlertClosed: hideCellWhenAlertClosed,
      openTask: openTask,
      changeTaskStatusToIdea: changeTaskStatusToIdea,
      changeTaskStatusToDeleted: changeTaskStatusToDeleted,
      alertIsHidden: alertIsHidden
    )
  }
}
