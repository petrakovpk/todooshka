//
//  KindOfTaskListViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 24.06.2021.
//

import RxFlow
import RxSwift
import RxCocoa
import Foundation

class KindOfTaskListViewModel: Stepper {
  
  //MARK: - Properties
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  let removeKindOfTaskIsRequired = BehaviorRelay<IndexPath?>(value: nil)
  let services: AppServices
  let steps = PublishRelay<Step>()
  
  struct Input {
    let addButtonClickTrigger: Driver<Void>
    let backButtonClickTrigger: Driver<Void>
    let cancelAlertButtonClickTrigger: Driver<Void>
    let deleteAlertButtonClickTrigger: Driver<Void>
    let moving: Driver<ItemMovedEvent?>
    let selection: Driver<IndexPath>
  }
  
  struct Output {
    let addTask: Driver<Void>
    let dataSource: Driver<[KindOfTaskListSection]>
    let hideAlert: Driver<Void>
    let moving: Driver<Result<Void,Error>>
    let navigateBack: Driver<Void>
    let openKindOfTask: Driver<Void>
    let removeKindOfTask: Driver<Result<Void,Error>>
    let showAlert: Driver<Void>
  }
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  func transform(input: Input) -> Output {
    
    let addTask = input.addButtonClickTrigger
      .map{ self.steps.accept(AppStep.CreateKindOfTaskIsRequired) }
    
    let kindsOfTask = services.dataService
      .kindsOfTask
      .map({ $0.filter{ $0.status == .active } })

    // dataSource
    let dataSource = kindsOfTask
      .map{[
        KindOfTaskListSection(
          header: "",
          items: $0
        )
      ]}.asDriver()
    
    let openKindOfTask = input.selection
      .withLatestFrom(dataSource){ $1[$0.section].items[$0.item] }
      .map{ self.steps.accept(AppStep.ShowKindOfTaskIsRequired(kindOfTask: $0)) }

    let moving = input.moving
      .compactMap{ $0 }
      .withLatestFrom(kindsOfTask) { itemMovedEvent, kindsOfTask -> [KindOfTask] in
        var kindsOfTask = kindsOfTask
        let element = kindsOfTask.remove(at: itemMovedEvent.sourceIndex.row)
        kindsOfTask.insert(element, at: itemMovedEvent.destinationIndex.row)
        return kindsOfTask
      }
      .distinctUntilChanged()
      .map { kindsOfTask -> [KindOfTask] in
        var kindsOfTask = kindsOfTask
        for (index, _) in kindsOfTask.enumerated() {
          kindsOfTask[index].index = index
        }
        return kindsOfTask
      }.asObservable()
      .flatMapLatest({ Observable.from($0) })
      .flatMapLatest({ self.appDelegate.persistentContainer.viewContext.rx.update($0) })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
   
    let removeKindOfTaskIsRequired = removeKindOfTaskIsRequired
      .asDriver()
      .compactMap{ $0 }

    // alert
    let showAlert = removeKindOfTaskIsRequired
      .map{ _ in () }
    
    let hideAlert = Driver
      .of(input.cancelAlertButtonClickTrigger, input.deleteAlertButtonClickTrigger)
      .merge()

    let removeKindOfTask = input.deleteAlertButtonClickTrigger
      .withLatestFrom(removeKindOfTaskIsRequired) { $1 }
      .withLatestFrom(dataSource) { $1[$0.section].items[$0.item] }
      .map{ kindOfTask -> KindOfTask in
        var kindOfTask = kindOfTask
        kindOfTask.status = .deleted
        return kindOfTask
      }
      .asObservable()
      .flatMapLatest({ self.appDelegate.persistentContainer.viewContext.rx.update($0) })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))

    let navigateBack = input.backButtonClickTrigger
      .map { self.steps.accept(AppStep.NavigateBack) }

    return Output(
      addTask: addTask,
      dataSource: dataSource,
      hideAlert: hideAlert,
      moving: moving,
      navigateBack: navigateBack,
      openKindOfTask: openKindOfTask,
      removeKindOfTask: removeKindOfTask,
      showAlert: showAlert
    )
  }
  
  func removeKindOfTaskIsRequired(indexPath: IndexPath) {
    removeKindOfTaskIsRequired.accept(indexPath)
  }
}
