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

  //MARK: - Init
  init(services: AppServices) {
    self.services = services
    
    services.coreDataService.taskTypes.bind{ [weak self] types in
      guard let self = self else { return }
      self.dataSource.accept([TaskTypeListSectionModel(header: "", items: types)])
    }
  }
  
  //MARK: - Handlers
  func leftBarButtonBackItemClick(){
    steps.accept(AppStep.taskTypesListIsCompleted)
  }
  
  func typeSelected(indexPath: IndexPath) {
    guard let type = services.coreDataService.taskTypes.value[safe: indexPath.item] else { return }
    steps.accept(AppStep.taskTypesListIsCompleted)
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
