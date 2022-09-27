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
    let syncButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    let deviceCountLabel: Driver<String>
    let firebaseCountLabel: Driver<String>
    let navigateBack: Driver<Void>
    let sync: Driver<Result<Void,Error>>
    let syncButtonIsEnabled: Driver<Bool>
  }
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  func transform(input: Input) -> Output {

    let deviceCount = services.dataService
      .tasks
      .map{ $0.filter{ $0.status != .Archive } }
      .map{ $0.count }
    
    let deviceCountLabel = deviceCount.map{ $0.string }
    
    let firebaseTasks = services.dataService.firebaseTasks
      .map{ $0.filter{ $0.status != .Archive } }
    
    let firebaseCount = firebaseTasks
      .map{ $0.count }
    
    let firebaseCountLabel = firebaseCount
      .map{ $0.string }
    
    let syncButtonIsEnabled = Driver.combineLatest(deviceCount, firebaseCount) { $0 != $1 }
    
    let sync = Driver
      .combineLatest(input.syncButtonClickTrigger, firebaseTasks ) { $1 }
      .asObservable()
      .flatMapLatest({ Observable.from($0) })
      .flatMapLatest({ task -> Observable<Result<Void, Error>> in
        self.appDelegate.persistentContainer.viewContext.rx.update(task)
      })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
  
    let navigateBack = input.backButtonClickTrigger
      .map { _ in self.steps.accept(AppStep.NavigateBack) }
    
    return Output(
      deviceCountLabel: deviceCountLabel,
      firebaseCountLabel: firebaseCountLabel,
      navigateBack: navigateBack,
      sync: sync,
      syncButtonIsEnabled: syncButtonIsEnabled
    )
  }
  
}


