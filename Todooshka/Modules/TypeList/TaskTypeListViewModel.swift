//
//  TaskTypesListViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 24.06.2021.
//

import RxFlow
import RxSwift
import RxCocoa

class TaskTypesListViewModel: Stepper {
  
  //MARK: - Properties
  let services: AppServices
  let steps = PublishRelay<Step>()
  
  struct Input {
    
    // buttons
    let addButtonClickTrigger: Driver<Void>
    let backButtonClickTrigger: Driver<Void>
    
    // alert
    let deleteAlertButtonClickTrigger: Driver<Void>
    let cancelAlertButtonClickTrigger: Driver<Void>
    
    // items
    let selection: Driver<IndexPath>
    let moving: Driver<ItemMovedEvent>
  }
  
  struct Output {
    
    // buttons
    let addTypeButtonClick: Driver<Void>
    let backButtonClick: Driver<Void>
    
    // dataSource
    let selection: Driver<TaskType>
    let moving: Driver<[TaskType]>
    let dataSource: Driver<[TaskTypeListSectionModel]>
    
    // alert
    let alertIsHidden: Driver<Bool>
    let alertCancelButtonClick: Driver<Void>
    let alertDeleteButtonClick: Driver<TaskType>
    
  }
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  func transform(input: Input) -> Output {
    
    // types
    let types = services.typesService
      .types
      .asDriver(onErrorJustReturn: [])
      .map {
        $0.filter {
          $0.status == .active
        }
      }
    
    let typeRemoving = services.typesService
      .typeRemovingIsRequired
      .asDriver()
    
    // buttons
    let addTypeButtonClick = input.addButtonClickTrigger
      .do { _ in
        self.steps.accept(AppStep.CreateTaskTypeIsRequired)
      }
    
    let backButtonClick = input.backButtonClickTrigger
      .do { _ in
        self.steps.accept(AppStep.TaskTypesListIsCompleted)
      }
    
    // dataSource
    let dataSource = services.typesService.types
      .map {
        [TaskTypeListSectionModel(header: "", items: $0.filter{ $0.status == .active })]
      }
      .asDriver(onErrorJustReturn: [])
    
    // selection
    let selection = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource in
        return dataSource[indexPath.section].items[indexPath.item]
      }
      .asDriver()
      .do { type in
        self.steps.accept(AppStep.ShowTaskTypeIsRequired(type: type))
      }
    
    // moving
    let moving = input.moving
      .filter { $0.sourceIndex != $0.destinationIndex }
      .withLatestFrom(types) { itemMovedEvent, types -> [TaskType] in
        var types = types
        let element = types.remove(at: itemMovedEvent.sourceIndex.row)
        types.insert(element, at: itemMovedEvent.destinationIndex.row)
        return types
      }
      .distinctUntilChanged()
      .asDriver()
      .do { types in
        var types = types
        for (index, _) in types.enumerated() {
          types[index].serialNum = index
        }
        self.services.typesService.saveTypesToCoreData(types: types)
      }
    
    // alert
    let alertIsHidden = services.typesService.typeRemovingIsRequired
      .map{ $0 == nil }
      .asDriver(onErrorJustReturn: true)
      
    let alertCancelButtonClick = input.cancelAlertButtonClickTrigger
      .do { _ in
        self.services.typesService.typeRemovingIsRequired.accept(nil)
      }
    
    let alertDeleteButtonClick = input.deleteAlertButtonClickTrigger
      .withLatestFrom(typeRemoving) { _, type -> TaskType? in
        guard var type = type else { return nil }
        type.status = .deleted
        return type
      }
      .compactMap{ $0 }
      .asDriver()
      .do { type in
        self.services.typesService.saveTypesToCoreData(types: [type])
        self.services.typesService.typeRemovingIsRequired.accept(nil)
      }

    return Output(
      // buttons
      addTypeButtonClick: addTypeButtonClick,
      backButtonClick: backButtonClick,
      
      // dataSource
      selection: selection,
      moving: moving,
      dataSource: dataSource,
      
      // alert
      alertIsHidden: alertIsHidden,
      alertCancelButtonClick: alertCancelButtonClick,
      alertDeleteButtonClick: alertDeleteButtonClick
    )
  }
  
  //MARK: - Lifecycle
  func viewWillDisappear() {
    services.typesService.typeRemovingIsRequired.accept(nil)
  }
}
