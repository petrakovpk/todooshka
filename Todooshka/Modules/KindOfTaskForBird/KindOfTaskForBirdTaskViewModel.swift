//
//  LinkBirdWIthKindOfTaskViewModel.swift
//  Todooshka
//
//  Created by Pavel Petakov on 22.09.2022.
//

import CoreData
import RxFlow
import RxSwift
import RxCocoa
import UIKit

class KindOfTaskForBirdViewModel: Stepper {
  
  // MARK: - Properties
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  var managedContext: NSManagedObjectContext { self.appDelegate.persistentContainer.viewContext }
  
  let birdUID: String
  let services: AppServices
  let steps = PublishRelay<Step>()
  
  struct Input {
//    let selection: Driver<IndexPath>
//    // alert
//    let alertDeleteButtonClick: Driver<Void>
//    let alertCancelButtonClick: Driver<Void>
//    // back
    let backButtonClickTrigger: Driver<Void>
    // add
//    let addTaskButtonClickTrigger: Driver<Void>
//    // remove all
//    let removeAllButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
//    let addTask: Driver<Void>
//    let change: Driver<Result<Void,Error>>
//    let hideAlert: Driver<Void>
//    let hideCell: Driver<IndexPath>
    let dataSource: Driver<[KindOfTaskListSection]>
    let navigateBack: Driver<Void>
//    let openTask: Driver<Void>
//    let removeAllTasks: Driver<Result<Void, Error>>
//    let removeTask: Driver<Result<Void, Error>>
//    let reloadData: Driver<[IndexPath]>
//    let setAlertText: Driver<String>
    
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

    let kindsOfTask = services.dataService.kindsOfTask
    let kindsOfTaskNotChangeable = services.dataService.kindsOfTaskNotChangeable
    
    // dataSource
    let dataSource = Driver
      .combineLatest(kindsOfTask, kindsOfTaskNotChangeable) { kindsOfTask, kindsOfTaskNotChangeable -> [KindOfTask] in
        kindsOfTask.filter{ kindOfTask in
          kindsOfTaskNotChangeable.contains(where: { $0.UID == kindOfTask.UID }) == false
        }
      }.map{[
        KindOfTaskListSection(
          header: "",
          items: $0
        )
      ]}
    
    // navigateBack
    let navigateBack = input.backButtonClickTrigger
      .map { self.steps.accept(AppStep.NavigateBack) }

    return Output(
      dataSource: dataSource,
      navigateBack: navigateBack
    )
  }

 
}
