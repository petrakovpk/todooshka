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
    // task
    let createTask: Driver<Void>
    // dataSource
    let nestDataSource: Driver<[Int: EggActionType]>
    let branchDataSource: Driver<[Int: BirdActionType]>
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
    
    services.tabBarService.selectedItem.accept(selectedItem == 1 ? .Left : .Right)
 
    // MARK: - Task
    let createTask = input.createTaskButtonClickTrigger
      .do { _ in self.steps.accept(AppStep.CreateTaskIsRequired(status: .InProgress, createdDate: nil)) }
    
    let tasks = services.dataService.tasks.asDriver()
    let selectedDate = services.preferencesService.selectedDate.asDriver()
    
    // MARK: - DataSource
    let nestDataSource = tasks
      .map { tasks -> [Int: EggActionType] in
        
        // dataSource
        var result: [Int: EggActionType] = [:]
        
        // Добавляем cracked задачи
        let completedTasks = tasks
          .filter{ $0.status == .Completed && Calendar.current.isDate($0.closed ?? Date(), inSameDayAs: Date()) }
          .sorted{ $0.closed! < $1.closed! }
        
        for (eggN, task) in completedTasks.enumerated() where completedTasks.count >= 1 && eggN <= 7 {
          result[eggN + 1] = .Crack(typeUID: task.kindOfTaskUID)
        }
        
        // Добавляем not cracked задачи
        let isProgressTasks = tasks
          .filter{ $0.status == .InProgress && $0.is24hoursPassed == false }
          .sorted{ $0.created < $1.created }
        
        for eggN in 0...isProgressTasks.count where eggN >= 1 && eggN <= 7 {
          result[completedTasks.count + eggN] = .NoCracks
        }
        
        // Добавляем Hidden задачи
        for eggN in 1...7 where eggN > completedTasks.count + isProgressTasks.count {
          result[eggN] = .Hide
        }
        
        return result
      }
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: [:])
      .do { dataSource in
        self.services.actionService.nestDataSource.accept(dataSource)
      }
    
    let birds = services.dataService.birds
    
    let branchDataSource = Driver
      .combineLatest(selectedDate, tasks, birds) { selectedDate, tasks, birds -> [Int: BirdActionType] in
        
        // dataSource
        var result: [Int: BirdActionType] = [:]
        
        // Добавляем sitting задачи
        let completedTasks = tasks
          .filter{ $0.status == .Completed && Calendar.current.isDate($0.closed ?? Date(), inSameDayAs: selectedDate ) }
          .sorted{ $0.closed! < $1.closed! }
        
        for (birdN, task) in completedTasks.enumerated() where completedTasks.count >= 1 && birdN <= 7 {
          let style = birds.first(where: { $0.kindsOfTaskUID.contains(task.kindOfTaskUID) })?.style ?? .Simple
          result[birdN + 1] = .Sitting(style: style, closed: task.closed!)
        }
        
        // Добавляем hiding задачи
        for birdN in 1...7 where birdN > completedTasks.count {
          result[birdN] = .Hide
        }
        
        return result
      }.distinctUntilChanged()
      .asDriver(onErrorJustReturn: [:])
      .do { dataSource in
        self.services.actionService.branchDataSource.accept(dataSource)
      }

    return Output(
      createTask: createTask,
      nestDataSource: nestDataSource,
      branchDataSource: branchDataSource
    )
  }
  
  
}
