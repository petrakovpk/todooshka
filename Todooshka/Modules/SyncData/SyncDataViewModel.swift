//
//  SyncDataViewModel.swift
//  Todooshka
//
//  Created by Pavel Petakov on 15.09.2022.
//

import Firebase
import RxFlow
import RxSwift
import RxCocoa

class SyncDataViewModel: Stepper {
  
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  let services: AppServices
  let steps = PublishRelay<Step>()

  struct Input {
    let backButtonClickTrigger: Driver<Void>
    let kindsOfTaskSyncButtonClickTrigger: Driver<Void>
    let taskSyncButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    let kindsOfTaskDeviceCountLabel: Driver<String>
    let kindsOfTaskFirebaseCountLabel: Driver<String>
    let kindsOfTaskSync: Driver<Result<Void,Error>>
    let kindsOfTaskSyncButtonIsEnabled: Driver<Bool>
    let navigateBack: Driver<Void>
    let taskDeviceCountLabel: Driver<String>
    let taskFirebaseCountLabel: Driver<String>
    let taskSync: Driver<Result<Void,Error>>
    let taskSyncButtonIsEnabled: Driver<Bool>
  }
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  func transform(input: Input) -> Output {

    let taskDeviceCount = services.dataService
      .tasks
      .map{ $0.filter{ $0.status != .Archive } }
      .map{ $0.count }
      .startWith(0)
    
    let taskDeviceCountLabel = taskDeviceCount
      .map{ $0.string }
    
    let firebaseTasks = services.dataService
      .firebaseTasks
      .asDriver()
      .map{ $0.filter{ $0.status != .Archive } }
        
    let taskFirebaseCount = firebaseTasks
      .map{ $0.count }
      .startWith(0)
    
    let taskFirebaseCountLabel = taskFirebaseCount
      .map{ $0.string }
    
    let taskSyncButtonIsEnabled = Driver
      .combineLatest(taskDeviceCount, taskFirebaseCount) { $0 < $1 }
    
    let taskSync = Driver
      .combineLatest(input.taskSyncButtonClickTrigger, firebaseTasks ) { $1 }
      .asObservable()
      .flatMapLatest({ Observable.from($0) })
      .filter{ $0.status != .Archive }
      .flatMapLatest({ task -> Observable<Result<Void, Error>> in
        self.appDelegate.persistentContainer.viewContext.rx.update(task)
      })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
    
    let kindsOfTaskDeviceCount = services.dataService
      .kindsOfTask
      .map{ $0.filter{ $0.status != .Archive } }
      .map{ $0.count }
      .startWith(0)
    
    let firebaseKindsOfTask = services.dataService
      .firebaseKindsOfTask
      .asDriver()
      .compactMap{ $0 }
      .map{ $0.filter{ $0.status != .Archive } }
    
    let kindsOfTaskDeviceCountLabel = kindsOfTaskDeviceCount
      .map{ $0.string }

    let kindsOfTaskFirebaseCount = firebaseKindsOfTask
      .map{ $0.count }
      .startWith(0)
    
    let kindsOfTaskFirebaseCountLabel = kindsOfTaskFirebaseCount
      .map{ $0.string }
    
    let kindsOfTaskSyncButtonIsEnabled = Driver
      .combineLatest(kindsOfTaskDeviceCount, kindsOfTaskFirebaseCount) { $0 < $1 }
    
    let kindsOfTaskSync = Driver
      .combineLatest(input.kindsOfTaskSyncButtonClickTrigger, firebaseKindsOfTask ) { $1 }
      .asObservable()
      .flatMapLatest({ Observable.from($0) })
      .filter{ $0.status != .Archive }
      .flatMapLatest({ kindofTask -> Observable<Result<Void, Error>> in
        self.appDelegate.persistentContainer.viewContext.rx.update(kindofTask)
      })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
  
    let navigateBack = input.backButtonClickTrigger
      .map { self.steps.accept(AppStep.NavigateBack) }
    
    return Output(
      kindsOfTaskDeviceCountLabel: kindsOfTaskDeviceCountLabel,
      kindsOfTaskFirebaseCountLabel: kindsOfTaskFirebaseCountLabel,
      kindsOfTaskSync: kindsOfTaskSync,
      kindsOfTaskSyncButtonIsEnabled: kindsOfTaskSyncButtonIsEnabled,
      navigateBack: navigateBack,
      taskDeviceCountLabel: taskDeviceCountLabel,
      taskFirebaseCountLabel: taskFirebaseCountLabel,
      taskSync: taskSync,
      taskSyncButtonIsEnabled: taskSyncButtonIsEnabled
    )
  }
  
}


