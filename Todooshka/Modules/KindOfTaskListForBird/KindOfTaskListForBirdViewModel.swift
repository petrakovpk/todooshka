//
//  KindOfTaskListForBirdViewModel.swift
//  Todooshka
//
//  Created by Pavel Petakov on 22.09.2022.
//

import CoreData
import RxFlow
import RxSwift
import RxCocoa
import UIKit

class KindOfTaskListForBirdViewModel: Stepper {
  
  // MARK: - Properties
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  var managedContext: NSManagedObjectContext { self.appDelegate.persistentContainer.viewContext }
  
  let birdUID: String
  let services: AppServices
  let steps = PublishRelay<Step>()
  
  struct Input {
    let selection: Driver<IndexPath>
//    // alert
    let alertCancelButtonClick: Driver<Void>
    let alertOkButtonClick: Driver<Void>
//    // back
    let backButtonClickTrigger: Driver<Void>
    // add
//    let addTaskButtonClickTrigger: Driver<Void>
//    // remove all
//    let removeAllButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    let add: Driver<Void>
    let alertTitleLabel: Driver<String>
//    let change: Driver<Result<Void,Error>>
//    let hideAlert: Driver<Void>
//    let hideCell: Driver<IndexPath>
    let dataSource: Driver<[KindOfTaskListSection]>
    let hideAlert: Driver<Void>
    let navigateBack: Driver<Void>
//    let openTask: Driver<Void>
//    let removeAllTasks: Driver<Result<Void, Error>>
//    let removeTask: Driver<Result<Void, Error>>
//    let reloadData: Driver<[IndexPath]>
    let showAlert: Driver<Void>
    
//    let title: Driver<String>
//    let showAlert: Driver<Void>
//    let showAddTaskButton: Driver<Void>
//    let showRemovaAllButton: Driver<Void>
  }
  
  //MARK: - Init
  init(services: AppServices, birdUID: String) {
    self.birdUID = birdUID
    self.services = services
  }
  
  func transform(input: Input) -> Output {
 
    let bird = services.dataService.birds
      .compactMap { $0.first(where: { $0.UID == self.birdUID }) }
    
    let birdsNotOpened = services.dataService.birds
      .withLatestFrom(bird) { birds, bird -> [Bird] in
        birds
          .filter{ $0.clade == bird.clade }
          .filter{ $0.isBought == false }
      }
    
    let kindsOfTask = services.dataService.kindsOfTask
   
    let kindsOfTaskNotLockedStyle = kindsOfTask
      .map { kindsOfTask -> [KindOfTask] in
        kindsOfTask.filter{ $0.isStyleLocked == false }
      }
    
    let kindsOfTaskLockedStyleNotOpenedBird = kindsOfTask
      .map { kindsOfTask -> [KindOfTask] in
        kindsOfTask.filter{ $0.isStyleLocked }
      }.withLatestFrom(birdsNotOpened) { kindsOfTask, birdsNotOpened -> [KindOfTask] in
        kindsOfTask.filter{ kindOfTask in
          birdsNotOpened.contains(where: { kindOfTask.style == $0.style })  }
      }
    
    let kindsOfTaskForDataSource = Driver
      .combineLatest(kindsOfTaskNotLockedStyle, kindsOfTaskLockedStyleNotOpenedBird) { kindsOfTask1, kindsOfTask2 -> [KindOfTask] in
        kindsOfTask1 + kindsOfTask2
      }.withLatestFrom(bird) { kindsOfTask, bird -> [KindOfTask] in
        kindsOfTask.filter{ $0.style != bird.style }
      }
    
    // dataSource
    let dataSource = kindsOfTaskForDataSource
      .map {[
        KindOfTaskListSection(
          header: "",
          items: $0
        )
      ]}
    
    let selection = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource -> KindOfTask in
        dataSource[indexPath.section].items[indexPath.item]
      }
    
    let alertTitleLabel = selection
      .map{ $0.isStyleLocked }
      .map{ $0 ? "Данный тип невозможно привязать, тк для него есть отдельный стиль! Если птица еще не открыта, данный тип будет отображаться в простой птице!" : "Привязать?" }
    
    let showAlert = selection
      .map { _ in () }
    
    let addTask = input.alertOkButtonClick
      .withLatestFrom(selection) { $1 }
      .filter{ $0.isStyleLocked == false }
      .withLatestFrom(bird) { kindOfTask, bird -> KindOfTask in
        var kindOfTask = kindOfTask
        kindOfTask.style = bird.style
        return kindOfTask
      }
      .asObservable()
      .flatMapLatest {
        self.managedContext.rx.update($0)
      }.asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))

    let addTaskSuccess = addTask
      .compactMap { result -> Void? in
        guard case .success(_) = result else { return nil }
        return ()
      }
    
    let hideAlert = Driver
      .of(input.alertCancelButtonClick, input.alertOkButtonClick)
      .merge()
    
    // navigateBack
    let navigateBack = input.backButtonClickTrigger
      .map { self.steps.accept(AppStep.NavigateBack) }

    return Output(
      add: addTaskSuccess,
      alertTitleLabel: alertTitleLabel,
      dataSource: dataSource,
      hideAlert: hideAlert,
      navigateBack: navigateBack,
      showAlert: showAlert
    )
  }

 
}
