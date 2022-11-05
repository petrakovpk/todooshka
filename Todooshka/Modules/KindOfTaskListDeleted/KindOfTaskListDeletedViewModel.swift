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

  // core data
  let appDelegate = UIApplication.shared.delegate as? AppDelegate
  var managedContext: NSManagedObjectContext? {
    return self.appDelegate?.persistentContainer.viewContext
  }

  // rx
  let disposeBag = DisposeBag()
  let services: AppServices
  let steps = PublishRelay<Step>()

  // custom
  let repeatKindOfTask = BehaviorRelay<IndexPath?>(value: nil)

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
    let removeAll: Driver<Result<Void, Error>>
    let repeatKindOfTask: Driver<Result<Void, Error>>
    let showAlert: Driver<Void>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {

    let kindsOfTask = services.dataService
      .kindsOfTask
      .map { $0.filter { $0.status == .deleted } }

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
      .compactMap { $0 }
      .withLatestFrom(dataSource) { $1[$0.section].items[$0.item] }
      .map { kindOfTask -> KindOfTask in
        var kindOfTask = kindOfTask
        kindOfTask.status = .active
        return kindOfTask
      }
      .flatMapLatest(({ self.managedContext?.rx.update($0) ?? Observable.of(.failure(ErrorType.managedContextNotFound)) }))
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))

    let showAlert = input.removeAllButtonClickTrigger

    let navigateBack = input.backButtonClickTrigger
      .map { self.steps.accept(AppStep.navigateBack) }

    let removeAll = input.alertDeleteButtonClickTrigger
      .withLatestFrom(kindsOfTask) { $1 }
      .asObservable()
      .flatMapLatest({ Observable.from($0) })
      .map { kindOfTask -> KindOfTask in
        var kindOfTask = kindOfTask
        kindOfTask.status = .archive
        return kindOfTask
      }
      .flatMapLatest({ self.managedContext?.rx.update($0) ?? Observable.of(.failure(ErrorType.managedContextNotFound)) })
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))

    return Output(
      dataSource: dataSource,
      hideAlert: hideAlert,
      navigateBack: navigateBack,
      removeAll: removeAll,
      repeatKindOfTask: repeatKindOfTask,
      showAlert: showAlert
    )
  }

  func repeatKindOfTask(indexPath: IndexPath) {
    repeatKindOfTask.accept(indexPath)
  }

}
