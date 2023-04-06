//
//  SyncDataViewModel.swift
//  Todooshka
//
//  Created by Pavel Petakov on 15.09.2022.
//

import CoreData
import Firebase
import RxFlow
import RxSwift
import RxCocoa

class SyncDataViewModel: Stepper {
  let appDelegate = UIApplication.shared.delegate as? AppDelegate
  var managedContext: NSManagedObjectContext? { self.appDelegate?.persistentContainer.viewContext }

  let services: AppServices
  let steps = PublishRelay<Step>()

  struct Input {
    let backButtonClickTrigger: Driver<Void>
    let kindsOfTaskSyncButtonClickTrigger: Driver<Void>
    let taskSyncButtonClickTrigger: Driver<Void>
  }

  struct Output {
//    let kindsOfTaskDeviceCountLabel: Driver<String>
//    let kindsOfTaskFirebaseCountLabel: Driver<String>
//    let kindsOfTaskSync: Driver<Result<Void, Error>>
//    let kindsOfTaskSyncButtonIsEnabled: Driver<Bool>
//    let navigateBack: Driver<Void>
//    let taskDeviceCountLabel: Driver<String>
//    let taskFirebaseCountLabel: Driver<String>
//    let taskSync: Driver<Result<Void, Error>>
//    let taskSyncButtonIsEnabled: Driver<Bool>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {
//    let taskDeviceCount = services.dataService
//      .tasks
//      .map { $0.filter { $0.status != .archive } }
//      .map { $0.count }
//      .startWith(0)
//
//    let taskDeviceCountLabel = taskDeviceCount
//      .map { $0.string }
//
//    let firebaseTasks = services.dataService
//      .firebaseTasks
//      .asDriver()
//      .compactMap { $0 }
//      .map { $0.filter { $0.status != .archive } }
//
//    let taskFirebaseCount = firebaseTasks
//      .map { $0.count }
//      .startWith(0)
//
//    let taskFirebaseCountLabel = taskFirebaseCount
//      .map { $0.string }
//
//    let taskSyncButtonIsEnabled = Driver
//      .combineLatest(taskDeviceCount, taskFirebaseCount) { $0 < $1 }
//
//    let taskSync = Driver
//      .combineLatest(input.taskSyncButtonClickTrigger, firebaseTasks ) { $1 }
//      .asObservable()
//      .flatMapLatest({ Observable.from($0) })
//      .filter { $0.status != .archive }
//      .flatMapLatest({ task -> Observable<Result<Void, Error>> in
//        self.managedContext?.rx.update(task) ?? Observable.of(.failure(ErrorType.managedContextNotFound))
//      })
//      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))
//
//    let kindsOfTaskDeviceCount = services.dataService
//      .kindsOfTask
//      .map { $0.filter { $0.status != .archive } }
//      .map { $0.count }
//      .startWith(0)
//
//    let firebaseKindsOfTask = services.dataService
//      .firebaseKindsOfTask
//      .asDriver()
//      .compactMap { $0 }
//      .map { $0.filter { $0.status != .archive } }
//
//    let kindsOfTaskDeviceCountLabel = kindsOfTaskDeviceCount
//      .map { $0.string }
//
//    let kindsOfTaskFirebaseCount = firebaseKindsOfTask
//      .map { $0.count }
//      .startWith(0)
//
//    let kindsOfTaskFirebaseCountLabel = kindsOfTaskFirebaseCount
//      .map { $0.string }
//
//    let kindsOfTaskSyncButtonIsEnabled = Driver
//      .combineLatest(kindsOfTaskDeviceCount, kindsOfTaskFirebaseCount) { $0 < $1 }
//
//    let kindsOfTaskSync = Driver
//      .combineLatest(input.kindsOfTaskSyncButtonClickTrigger, firebaseKindsOfTask ) { $1 }
//      .asObservable()
//      .flatMapLatest({ Observable.from($0) })
//      .filter { $0.status != .archive }
//      .flatMapLatest({ kindofTask -> Observable<Result<Void, Error>> in
//        self.managedContext?.rx.update(kindofTask) ?? Observable.of(.failure(ErrorType.managedContextNotFound))
//      })
//      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))
//
//    let navigateBack = input.backButtonClickTrigger
//      .map { self.steps.accept(AppStep.navigateBack) }

    return Output(
//      kindsOfTaskDeviceCountLabel: kindsOfTaskDeviceCountLabel,
//      kindsOfTaskFirebaseCountLabel: kindsOfTaskFirebaseCountLabel,
//      kindsOfTaskSync: kindsOfTaskSync,
//      kindsOfTaskSyncButtonIsEnabled: kindsOfTaskSyncButtonIsEnabled,
//      navigateBack: navigateBack,
//      taskDeviceCountLabel: taskDeviceCountLabel,
//      taskFirebaseCountLabel: taskFirebaseCountLabel,
//      taskSync: taskSync,
//      taskSyncButtonIsEnabled: taskSyncButtonIsEnabled
    )
  }
}
