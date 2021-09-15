//
//  TaskTypesListViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 24.06.2021.
//

import RxFlow
import RxSwift
import RxCocoa
import Firebase

class TaskTypesListViewModel: Stepper {
  
  //MARK: - Properties
  let services: AppServices
  let steps = PublishRelay<Step>()
  let dataSource = BehaviorRelay<[TaskTypeListSectionModel]>(value: [])
  
  private let disposeBag = DisposeBag()
  
  let showAlert = BehaviorRelay<Bool>(value: false)
  let alertLabelOutput = BehaviorRelay<String>(value: "Удалить тип?")
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
    
    services.coreDataService.taskTypes.bind{ [weak self] types in
      guard let self = self else { return }
      
      var models: [TaskTypeListSectionModel] = []
      models.append(TaskTypeListSectionModel(header: "", items: types.filter{ $0.status == .active } ))
      self.dataSource.accept(models)
    }.disposed(by: disposeBag)
    
    services.coreDataService.taskTypeRemovingIsRequired.bind{ [weak self] taskType in
      guard let self = self else { return }
      guard let taskType = taskType else {
        self.showAlert.accept(false)
        return
      }
      
      self.alertLabelOutput.accept("Удалить тип \(taskType.text)?")
      self.showAlert.accept(true)
    }.disposed(by: disposeBag)
  }
  
  //MARK: - Lifecycle
  func viewWillDisappear() {
    services.coreDataService.taskTypeRemovingIsRequired.accept(nil)
  }
  
  //MARK: - Handlers
  func leftBarButtonBackItemClick(){
    steps.accept(AppStep.taskTypesListIsCompleted)
  }
  
  func alertDeleteButtonClicked() {
    
    if let type = services.coreDataService.taskTypeRemovingIsRequired.value {
      type.status = .deleted
      services.coreDataService.saveTaskTypesToCoreData(types: [type]) { error in
        if let error = error  {
          print(error.localizedDescription)
          return
        }
        self.services.coreDataService.taskTypeRemovingIsRequired.accept(nil)
      }
    }
  }
  
  func alertCancelButtonClicked() {
    services.coreDataService.taskTypeRemovingIsRequired.accept(nil)
  }
  
  func collectionViewItemMoved(sourceIndex: IndexPath, destinationIndex: IndexPath) {
    guard sourceIndex != destinationIndex else { return }
    var taskTypes = services.coreDataService.taskTypes.value
    
    let element = taskTypes.remove(at: sourceIndex.row)
    taskTypes.insert(element, at: destinationIndex.row)
    
    for (index, _) in taskTypes.enumerated() {
      taskTypes[index].orderNumber = index
    }
    
    services.coreDataService.taskTypes.accept(taskTypes)
  }
  
  func collectionViewItemSelected(indexPath: IndexPath) {
    let taskType = dataSource.value[indexPath.section].items[indexPath.item]
    steps.accept(AppStep.taskTypeIsRequired(type: taskType))
  }
  
  func addTaskTypeButtonClick() {
    steps.accept(AppStep.taskTypeIsRequired(type: nil))
  }
}
