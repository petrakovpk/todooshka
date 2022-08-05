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
   // let didSelectItemTrigger: Driver<UITabBarItem>
  }
  
  struct Output {
    // task
    let createTask: Driver<Void>
    // actions
    let createNestSceneActions: Driver<[NestSceneAction]>
    let createBranchSceneActions: Driver<[BranchSceneAction]>
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
 
    // MARK: - Task
    let createTask = input.createTaskButtonClickTrigger
      .do { _ in self.steps.accept(AppStep.CreateTaskIsRequired(status: .InProgress, createdDate: nil)) }
    
    // MARK: - Nest Scene Actions
    let createTheEggAction = services.tasksService.tasks
      .withPrevious(startWith: [])
      .map { oldTasks, newTasks -> [NestSceneAction] in
        newTasks
          .filter { newTask -> Bool in
            newTask.status == .InProgress &&
            newTask.status != oldTasks.first(where: { $0.UID == newTask.UID })?.status
          }
          .map { _ in
            NestSceneAction(UID: UUID().uuidString, action: .AddTheEgg(withAnimation: true))
          }
      }
      .flatMapLatest { Driver.just($0) }
      .filter { $0.isEmpty == false }
      .asDriver(onErrorJustReturn: [])

    let removeTheEggAction = services.tasksService.tasks
      .withPrevious(startWith: [])
      .map { oldTasks, newTasks -> [NestSceneAction] in
        oldTasks
          .filter { task -> Bool in
            newTasks.contains(where: {
              task.status == .InProgress &&
              $0.UID == task.UID &&
              $0.status != .InProgress && $0.status != .Completed
            })
          }
          .map { _ in
            NestSceneAction(UID: UUID().uuidString, action: .RemoveTheEgg)
          }
      }
      .flatMapLatest { Driver.just($0) }
      .filter { $0.isEmpty == false }
      .asDriver(onErrorJustReturn: [])
     
    let hatchTheBirdAction = services.tasksService.tasks
      .withPrevious(startWith: [])
      .map { oldTasks, newTasks -> [NestSceneAction] in
        oldTasks
          .filter { oldTasks -> Bool in
            newTasks.contains(where: {
              oldTasks.status == .InProgress &&
              oldTasks.UID == $0.UID &&
              $0.status == .Completed
            })
          }
          .map { task -> NestSceneAction in
            NestSceneAction(
              UID: UUID().uuidString,
              action: .HatchTheBird(typeUID: task.typeUID)
            )
          }
      }
      .flatMapLatest { Driver.just($0) }
      .filter { $0.isEmpty == false }
      .asDriver(onErrorJustReturn: [])
    
    // MARK: - Branch Scene Actions
    let runTheBirdAction = services.tasksService.tasks
      .withPrevious(startWith: [])
      .map { oldTasks, newTasks -> [BranchSceneAction] in
        newTasks
          .filter { newTask -> Bool in
            oldTasks.contains(where: { oldTask -> Bool in
              oldTask.UID == newTask.UID &&
              oldTask.status == .InProgress &&
              newTask.status == .Completed
            })
          }.map { task -> BranchSceneAction in
            BranchSceneAction(
              UID: UUID().uuidString,
              action: .AddTheRunningBird(
                birds: self.services.birdService.birds.value,
                typeUID: task.typeUID,
                withDelay: (Date().timeIntervalSince1970 - task.closed!.timeIntervalSince1970) < 4 )
            )
          }
      }
      .flatMapLatest { Driver.just($0) }
      .filter { $0.isEmpty == false }
      .asDriver(onErrorJustReturn: [])
    
    let createNestSceneActions = Driver.of(
      createTheEggAction,
      hatchTheBirdAction,
      removeTheEggAction
      ).merge()
      .do {
        self.services.actionService.addNestSceneActions(actions: $0)
      }
    
    let createBranchSceneActions = Driver.of(
      runTheBirdAction
      ).merge()
      .do {
        self.services.actionService.addBranchSceneActions(actions: $0)
      }
    
    return Output(
      createTask: createTask,
      createNestSceneActions: createNestSceneActions,
      createBranchSceneActions: createBranchSceneActions
    )
  }
  

}
