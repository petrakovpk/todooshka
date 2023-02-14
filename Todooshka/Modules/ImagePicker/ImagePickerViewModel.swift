//
//  ImagePickerViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 30.01.2023.
//

import CoreData
import Firebase
import RxFlow
import RxSwift
import RxCocoa
import UIKit

class ImagePickerViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  public let cancelButtonClickTrigger = PublishRelay<Void>()
  public let imageButtonClickTrigger = PublishRelay<[UIImagePickerController.InfoKey: Any]>()
  
  private let appDelegate = UIApplication.shared.delegate as! AppDelegate
  private let services: AppServices
  private let task: Task

  private var managedContext: NSManagedObjectContext { appDelegate.persistentContainer.viewContext }

  struct Input {
    
  }
  
  struct Output {
    let addPhoto: Driver<Void>
    let dismiss: Driver<Void>
  }

  // MARK: - Init
  init(services: AppServices, task: Task) {
    self.services = services
    self.task = task
  }

  func transform(input: Input) -> Output {
    let cancelButtonClickTrigger = cancelButtonClickTrigger.asDriverOnErrorJustComplete()
    let imageButtonClickTrigger = imageButtonClickTrigger.asDriverOnErrorJustComplete()
    
    let addPhoto = imageButtonClickTrigger
      .compactMap{ info -> UIImage? in
        info[UIImagePickerController.InfoKey.originalImage] as? UIImage
      }
      .map { image -> Task in
        var task = self.task
        task.image = image
        return task
      }
      .asObservable()
      .flatMapLatest { self.managedContext.rx.update($0) }
      .asDriverOnErrorJustComplete()
      .mapToVoid()
      .do { _ in
        self.steps.accept(AppStep.dismiss)
      }
    
   
    let dismiss = cancelButtonClickTrigger
      .do { _ in
        self.steps.accept(AppStep.dismiss)
      }
    
    return Output(
      addPhoto: addPhoto,
      dismiss: dismiss
    )
  }
}


