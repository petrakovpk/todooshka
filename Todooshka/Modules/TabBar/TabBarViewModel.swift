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
    let createActions: Driver<[SceneAction]>
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
 
    // createTask
    let createTask = input.createTaskButtonClickTrigger
      .map { self.steps.accept(AppStep.CreateTaskIsRequired(status: .InProgress, createdDate: nil)) }
    
    // actions
    let createTheEggAction = services.tasksService.tasks
      .withPrevious(startWith: [])
      .map { previous, current -> [SceneAction] in
        current
          .filter { task -> Bool in
            task.status == .InProgress &&
            task.status != previous.first(where: { $0.UID == task.UID })?.status
          }
          .map { _ in
            SceneAction(UID: UUID().uuidString, action: .CreateTheEgg(withAnimation: true))
          }
      }
      .flatMapLatest { Driver.just($0) }
      .filter { $0.isEmpty == false }
      .asDriver(onErrorJustReturn: [])

    let removeTheEggAction = services.tasksService.tasks
      .withPrevious(startWith: [])
      .map { previous, current -> [SceneAction] in
        previous
          .filter { task -> Bool in
            current.contains(where: {
              task.status == .InProgress &&
              $0.UID == task.UID &&
              $0.status != .InProgress && $0.status != .Completed
            })
          }
          .map { _ in
            SceneAction(UID: UUID().uuidString, action: .RemoveTheEgg)
          }
      }
      .flatMapLatest { Driver.just($0) }
      .filter { $0.isEmpty == false }
      .asDriver(onErrorJustReturn: [])
     
    let hatchTheBirdAction = services.tasksService.tasks
      .withPrevious(startWith: [])
      .map { previous, current -> [SceneAction] in
        previous
          .filter { previous -> Bool in
            current.contains(where: {
              previous.status == .InProgress &&
              previous.UID == $0.UID &&
              $0.status == .Completed
            })
          }
          .map { task -> SceneAction in
            SceneAction(
              UID: UUID().uuidString,
              action: .HatchTheBird(
                birds: self.services.birdService.birds.value
                  .filter({ $0.typesUID.contains(where: { $0 == task.typeUID }) })
              )
            )
          }
      }
      .flatMapLatest { Driver.just($0) }
      .filter { $0.isEmpty == false }
      .asDriver(onErrorJustReturn: [])
    
    let runTheBirdAction =  services.tasksService.tasks
      .withPrevious(startWith: [])
      .map { previous, current -> [SceneAction] in
        previous
          .filter { previous -> Bool in
            current.contains(where: {
              previous.status == .InProgress &&
              previous.UID == $0.UID &&
              $0.status == .Completed
            })
          }
          .map { task -> SceneAction in
            SceneAction(
              UID: UUID().uuidString,
              action: .RunTheBird(
                birds: self.services.birdService.birds.value
                  .filter({ $0.typesUID.contains(where: { $0 == task.typeUID }) }),
                created: Date()
              )
            )
          }
      }
      .flatMapLatest { Driver.just($0) }
      .filter { $0.isEmpty == false }
      .asDriver(onErrorJustReturn: [])
    
    let createActions = Driver.of(
      createTheEggAction,
      hatchTheBirdAction,
      removeTheEggAction,
      runTheBirdAction
    )
      .merge()
      .do {
        self.services.actionService.addActions(actions: $0)
      }
    
    return Output(
      createTask: createTask,
      createActions: createActions
    )
  }
  

}
