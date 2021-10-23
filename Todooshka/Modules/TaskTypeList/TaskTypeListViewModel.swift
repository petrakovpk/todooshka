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
  
  struct Input {
    let addButtonClickTrigger: Driver<Void>
    let backButtonClickTrigger: Driver<Void>
    let deleteAlertButtonClickTrigger: Driver<Void>
    let cancelAlertButtonClickTrigger: Driver<Void>
    let itemSelected: Driver<IndexPath>
    let itemMoved: Driver<ItemMovedEvent?>
  }
  
  struct Output {
    let dataSource: Driver<[TaskTypeListSectionModel]>
    let typeSelected: Driver<Void>
    let addTypeButtonClick: Driver<Void>
    let backButtonClick: Driver<Void>
    let showAlert: Driver<Bool>
    let cancelAlertButtonClick: Driver<Void>
    let deleteAelrtButtonClick: Driver<Void>
    let itemMoved: Driver<Void>
  }
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  func transform(input: Input) -> Output {
    
    let dataSource = services.coreDataService.taskTypes.map { types -> [TaskTypeListSectionModel] in
      return [TaskTypeListSectionModel(header: "", items: types.filter{ $0.status == .active } )]
    }.asDriver(onErrorJustReturn: [])
    
    let typeSelected = input.itemSelected.withLatestFrom(dataSource) { indexPath, dataSource in
      let type = dataSource[indexPath.section].items[indexPath.item]
      self.steps.accept(AppStep.taskTypeIsRequired(type: type))
    }
    
    let addTypeButtonClick = input.addButtonClickTrigger.map { self.steps.accept(AppStep.taskTypeIsRequired(type: nil)) }
    let backButtonClick = input.backButtonClickTrigger.map { self.steps.accept(AppStep.taskTypesListIsCompleted) }
    
    let showAlert = services.coreDataService.taskTypeRemovingIsRequired.map{ type -> Bool in
      return type != nil
    }.asDriver(onErrorJustReturn: false)
    
    let cancelAlertButtonClick = input.cancelAlertButtonClickTrigger.map { self.services.coreDataService.taskTypeRemovingIsRequired.accept(nil)
    }
    
    let deleteAlertButtonClick = input.deleteAlertButtonClickTrigger.map {
      guard let type = self.services.coreDataService.taskTypeRemovingIsRequired.value else { return }
      type.status = .deleted
      self.services.coreDataService.saveTaskTypesToCoreData(types: [type]) { error in
        if let error = error  {
          print(error.localizedDescription)
          return
        }
        self.services.coreDataService.taskTypeRemovingIsRequired.accept(nil)
      }
    }
    
    let itemMoved = input.itemMoved.map { (itemMovedEvent) in
      guard let sourceIndex = itemMovedEvent?.sourceIndex else { return }
      guard let destinationIndex = itemMovedEvent?.destinationIndex else { return }
      
      guard sourceIndex != destinationIndex else { return }
      var taskTypes = self.services.coreDataService.taskTypes.value.filter{$0.status == .active}
      let element = taskTypes.remove(at: sourceIndex.row)
      taskTypes.insert(element, at: destinationIndex.row)

      for (index, _) in taskTypes.enumerated() {
        taskTypes[index].orderNumber = index
      }
      self.services.coreDataService.saveTaskTypesToCoreData(types: taskTypes) { error in
        if let error = error  {
          print(error.localizedDescription)
          return
        }
      }
    }
    
    return Output(
      dataSource: dataSource,
      typeSelected: typeSelected,
      addTypeButtonClick: addTypeButtonClick,
      backButtonClick: backButtonClick,
      showAlert: showAlert,
      cancelAlertButtonClick: cancelAlertButtonClick,
      deleteAelrtButtonClick: deleteAlertButtonClick,
      itemMoved: itemMoved
    )
  }
  
  //MARK: - Lifecycle
  func viewWillDisappear() {
    services.coreDataService.taskTypeRemovingIsRequired.accept(nil)
  }
}
