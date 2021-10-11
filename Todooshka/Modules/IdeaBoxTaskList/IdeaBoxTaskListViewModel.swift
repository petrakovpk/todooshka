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
  let dataSource = BehaviorRelay<[TaskListSectionModel]>(value: [])
  let disposeBag = DisposeBag()
  let services: AppServices
  let formatter = DateFormatter()
  let showAlert = BehaviorRelay<Bool>(value: false)

  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
    
    formatter.dateFormat = "d MMMM yyyy"
    formatter.timeZone =  TimeZone(abbreviation: "UTC")
    formatter.locale = Locale(identifier: "ru")
    
    services.coreDataService.tasks
      .map({$0.filter{ $0.status == .idea }})
      .bind { [weak self] tasks in
        guard let self = self else { return }
        
        let tasksDict = Dictionary(grouping: tasks , by: { $0.type?.text ?? "" }).sorted{ $0.key > $1.key }
        var models: [TaskListSectionModel] = []
        
        for taskDict in tasksDict {
          models.append(TaskListSectionModel(header: taskDict.key, items: taskDict.value.sorted{ $0.orderNumber < $1.orderNumber }))
        }
        
        self.dataSource.accept(models)
      }.disposed(by: disposeBag)
    
    services.coreDataService.taskRemovingIsRequired.bind{ [weak self] task in
      guard let self = self else { return }
      self.showAlert.accept(task?.status == .idea)
    }.disposed(by: disposeBag)
    
  }
  
  func openTask(indexPath: IndexPath) {
    let task = dataSource.value[indexPath.section].items[indexPath.item]
    steps.accept(AppStep.showTaskIsRequired(task: task))
  }
  
  //MARK: Collectionview Moved
  func collectionViewItemMoved(sourceIndex: IndexPath, destinationIndex: IndexPath) {
      
    guard sourceIndex != destinationIndex else { return }
    guard sourceIndex.section == destinationIndex.section else { return }
    
    var tasks = dataSource.value[sourceIndex.section].items
    
    let element = tasks.remove(at: sourceIndex.row)
    tasks.insert(element, at: destinationIndex.row)
   
    for (index, _) in tasks.enumerated() {
      tasks[index].orderNumber = index
    }
  
    services.coreDataService.saveTasksToCoreData(tasks: tasks, completion: nil)
  }
  
  //MARK: - Handlers
  func leftBarButtonBackItemClick() {
    steps.accept(AppStep.ideaBoxTaskListIsCompleted)
  }
  
  func rightBarButtonAddItemClick() {
    steps.accept(AppStep.createTaskIsRequired(status: .idea, createdDate: nil) )
  }
  
  func alertCancelButtonClicked() {
    services.coreDataService.taskRemovingIsRequired.accept(nil)
  }
  
  func alertDeleteButtonClicked() {
    if let task = services.coreDataService.taskRemovingIsRequired.value {
      task.status = .deleted
      services.coreDataService.saveTasksToCoreData(tasks: [task]) { error in
        if let error = error  {
          print(error.localizedDescription)
          return
        }
        self.services.coreDataService.taskRemovingIsRequired.accept(nil)
      }
    }
  }
}
