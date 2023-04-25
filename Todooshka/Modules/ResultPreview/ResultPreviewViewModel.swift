//
//  ResultPreviewViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 02.03.2023.
//

import CoreData
import RxFlow
import RxSwift
import RxCocoa
import UIKit

class ResultPreviewViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  private let services: AppServices
  
  private let appDelegate = UIApplication.shared.delegate as! AppDelegate
  private var managedContext: NSManagedObjectContext { appDelegate.persistentContainer.viewContext }
  
  private var task: Task
  
  struct Input {
    let backButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    let navigateBack: Driver<Void>
    let text: Driver<String>
    let image: Driver<UIImage>
  }
  
  init(services: AppServices, task: Task) {
    self.services = services
    self.task = task
  }

  func transform(input: Input) -> Output {
    let navigateBack = input.backButtonClickTrigger
      .do { _ in self.steps.accept(AppStep.navigateBack) }
    
    let task = managedContext.rx
      .entities(
        Task.self,
        predicate: NSPredicate(format: "uuid == %@", task.uuid.uuidString ))
      .compactMap { $0.first }
      .asDriverOnErrorJustComplete()
      .startWith(self.task)
    
    let text = task
      .map { $0.text }
    
//    let image = task
//      .asObservable()
//      .flatMapLatest { task -> Observable<[Image]> in
//        self.managedContext.rx.entities(
//          Image.self,
//          predicate: NSPredicate(format: "uuid == %@", task.imageUUID?.uuidString ?? ""))
//      }
//      .compactMap { $0.first }
//      .map { $0.image }
//      .asDriverOnErrorJustComplete()
    
    let image = Driver<UIImage>.of(UIImage())
 
    return Output (
      navigateBack: navigateBack,
      text: text,
      image: image
    )
  }
}
