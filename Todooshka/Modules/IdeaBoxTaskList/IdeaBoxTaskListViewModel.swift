//
//  IdeaBoxTaskListViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 09.07.2021.
//
import RxFlow
import RxSwift
import RxCocoa
import Firebase

class IdeaBoxTaskListViewModel: Stepper {
  
  //MARK: - Properties
  let steps = PublishRelay<Step>()
  //let dataSource = BehaviorRelay<[TaskListSectionModel]>(value: [])
  //let disposeBag = DisposeBag()
  let services: AppServices
  let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMMM yyyy"
    formatter.timeZone =  TimeZone(abbreviation: "UTC")
    formatter.locale = Locale(identifier: "ru")
    return formatter
  }()
  //let showAlert = BehaviorRelay<Bool>(value: false)
  
  struct Input {
    let backButtonClickTrigger: Driver<Void>
    let addButtonClickTrigger: Driver<Void>
    let alertDeleteButtonClickTrigger: Driver<Void>
    let alertCancelButtonClickTrigger: Driver<Void>
    let selection: Driver<IndexPath>
  }
  
  struct Output {
    let dataSource: Driver<[TaskListSectionModel]>
    let alertIsHidden: Driver<Bool>
    let backButtonClicked: Driver<Void>
    let addButtonClicked: Driver<Void>
    let alertDeleteButtonClicked: Driver<Void>
    let alertCancelButtonClicked: Driver<Void>
    let taskSelected: Driver<Void>
  }
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  func transform(input: Input) -> Output {
    
    let dataSource = services.coreDataService.tasks
      .map { tasks -> [TaskListSectionModel] in
        let tasks = tasks.filter{ $0.status == .idea }
        let tasksDict = Dictionary(grouping: tasks, by: { $0.type?.text ?? "Нет типа" }).sorted{ $0.key > $1.key }
        var models: [TaskListSectionModel] = []
        for taskDict in tasksDict {
          models.append(TaskListSectionModel(header: taskDict.key, items: taskDict.value.sorted{ $0.text < $1.text }))
        }
        return models
      }.asDriver(onErrorJustReturn: [])
    
    let alertIsHidden = services.coreDataService.taskRemovingIsRequired.map{ return $0 == nil }.asDriver(onErrorJustReturn: false)
    
    let backButtonClicked = input.backButtonClickTrigger.map{ self.steps.accept(AppStep.ideaBoxTaskListIsCompleted) }
    let addButtonClicked = input.addButtonClickTrigger.map{ self.steps.accept(AppStep.createTaskIsRequired(status: .idea, createdDate: nil)) }
    let alertCancelButtonClicked = input.alertCancelButtonClickTrigger.map{ self.services.coreDataService.taskRemovingIsRequired.accept(nil) }
    
    let alertDeleteButtonClicked = input.alertDeleteButtonClickTrigger.map {
      guard let task = self.services.coreDataService.taskRemovingIsRequired.value else { return }
      task.status = .deleted
      self.services.coreDataService.saveTasksToCoreData(tasks: [task]) { error in
        if let error = error  {
          print(error.localizedDescription)
          return
        }
        self.services.coreDataService.taskRemovingIsRequired.accept(nil)
      }
    }
    
    let taskSelected = input.selection.withLatestFrom(dataSource) { indexPath, dataSource in
      let task = dataSource[indexPath.section].items[indexPath.item]
      self.steps.accept(AppStep.showTaskIsRequired(task: task))
    }
    
    return Output(
      dataSource: dataSource,
      alertIsHidden: alertIsHidden,
      backButtonClicked: backButtonClicked,
      addButtonClicked: addButtonClicked,
      alertDeleteButtonClicked: alertDeleteButtonClicked,
      alertCancelButtonClicked: alertCancelButtonClicked,
      taskSelected: taskSelected
    )
  }
}

