//
//  DeletedTaskTypesListViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 14.09.2021.
//

import RxFlow
import RxSwift
import RxCocoa
import Firebase

class DeletedTaskTypesListViewModel: Stepper {
  
  let steps = PublishRelay<Step>()
  let dataSource = BehaviorRelay<[TaskTypeListSectionModel]>(value: [])
  let disposeBag = DisposeBag()
  let services: AppServices
  
  let showAlert = BehaviorRelay<Bool>(value: false)
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
    
    services.coreDataService.taskTypes.bind{ [weak self] types in
      guard let self = self else { return }
      var models: [TaskTypeListSectionModel] = []
      models.append(TaskTypeListSectionModel(header: "", items: types.filter{ $0.status == .deleted } ))
      self.dataSource.accept(models)
    }.disposed(by: disposeBag)
    
    services.coreDataService.allTaskTypesRemovingIsRequired.bind(to: showAlert).disposed(by: disposeBag)
  }
  
  //MARK: - Handlers
  func leftBarButtonBackItemClick() {
    steps.accept(AppStep.deletedTaskListIsCompleted)
  }
  
  func removeAllTaskTypesButtonClick() {
    services.coreDataService.allTaskTypesRemovingIsRequired.accept(true)
  }
  
  func alertCancelButtonClicked() {
    services.coreDataService.allTaskTypesRemovingIsRequired.accept(false)
  }
  
  func alertDeleteButtonClicked() {
    if let types = dataSource.value.first?.items {
      services.coreDataService.removeTaskTypesFromCoreData(types: types) {[weak self] error in
        guard let self = self else { return }
        if let error = error {
          print(error.localizedDescription)
        }
        self.services.coreDataService.allTaskTypesRemovingIsRequired.accept(false)
      }
    }
  }
  
}
