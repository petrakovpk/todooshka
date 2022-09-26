//
//  KindOfTaskListDeletedViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 14.09.2021.
//

import CoreData
import RxCocoa
import RxFlow
import RxSwift


class KindOfTaskListDeletedViewModel: Stepper {
  
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  let disposeBag = DisposeBag()
  var managedContext: NSManagedObjectContext {
    return self.appDelegate.persistentContainer.viewContext
  }
  let repeatKindOfTask = BehaviorRelay<IndexPath?>(value: nil)
  let services: AppServices
  let steps = PublishRelay<Step>()
  
  struct Input {
    let alertCancelButtonClickTrigger: Driver<Void>
    let alertDeleteButtonClickTrigger: Driver<Void>
    let backButtonClickTrigger: Driver<Void>
    let removeAllButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    let dataSource: Driver<[KindOfTaskListSection]>
    let hideAlert: Driver<Void>
    let navigateBack: Driver<Void>
    let removeAllKindsOfTask: Driver<Result<Void,Error>>
    let repeatKindOfTask: Driver<Result<Void,Error>>
    let showAlert: Driver<Void>
  }
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  func transform(input: Input) -> Output {
    
    let kindsOfTask = services.dataService
      .kindsOfTask
      .map{ $0.filter{ $0.status == .deleted } }
    
    let dataSource = kindsOfTask
      .map {[
        KindOfTaskListSection(
          header: "",
          items: $0
        )
      ]}
    
    let hideAlert = Driver
      .of(input.alertCancelButtonClickTrigger, input.alertDeleteButtonClickTrigger)
      .merge()
    
    let repeatKindOfTask = repeatKindOfTask
      .compactMap{ $0 }
      .withLatestFrom(dataSource) { $1[$0.section].items[$0.item] }
      .map { kindOfTask -> KindOfTask in
        var kindOfTask = kindOfTask
        kindOfTask.status = .active
        return kindOfTask
      }
      .debug()
      .flatMapLatest(({ self.managedContext.rx.update($0) }))
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
    
    let showAlert = input.removeAllButtonClickTrigger
    
    let navigateBack = input.backButtonClickTrigger
      .map{ self.steps.accept(AppStep.NavigateBack) }
    
    let removeAllKindsOfTask = input.alertDeleteButtonClickTrigger
      .withLatestFrom(kindsOfTask) { $1 }
      .asObservable()
      .flatMapLatest({ Observable.from($0) })
      .flatMapLatest({ self.appDelegate.persistentContainer.viewContext.rx.delete($0) })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
    
    return Output(
      dataSource: dataSource,
      hideAlert: hideAlert,
      navigateBack: navigateBack,
      removeAllKindsOfTask: removeAllKindsOfTask,
      repeatKindOfTask: repeatKindOfTask,
      showAlert: showAlert
    )
  }
  
  func repeatKindOfTask(indexPath: IndexPath) {
    repeatKindOfTask.accept(indexPath)
  }
  
}

