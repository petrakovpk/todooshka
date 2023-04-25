//
//  ImagePickerViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 30.01.2023.
//

import CoreData
import Firebase
import FirebaseStorage
import RxFlow
import RxSwift
import RxCocoa
import UIKit

class ImagePickerViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  public let cancelButtonClickTrigger = PublishRelay<Void>()
  public let imageButtonClickTrigger = PublishRelay<[UIImagePickerController.InfoKey: Any]>()
  
  private let services: AppServices
  private let task: Task

  private let appDelegate = UIApplication.shared.delegate as! AppDelegate
  private var managedContext: NSManagedObjectContext { appDelegate.persistentContainer.viewContext }

  struct Input {
    
  }
  
  struct Output {
  //  let saveImage: Driver<Result<Void, any Error>>
  //  let updateTask: Driver<Result<Void, any Error>>
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

    let selectedImage = imageButtonClickTrigger
      .compactMap { info -> UIImage? in
        info[UIImagePickerController.InfoKey.originalImage] as? UIImage
      }
      .map { image -> Image in
        Image(
          uuid: UUID(),
          imageData: image.pngData()!)
      }
    
//    let saveImage = selectedImage
//      .asObservable()
//      .flatMapLatest { self.managedContext.rx.update($0) }
//      .asDriverOnErrorJustComplete()
    
//    let updateTask = selectedImage
//      .map { image -> Task in
//        var task = self.task
//        task.imageUUID = image.uuid
//        return task
//      }
//      .asObservable()
//      .flatMapLatest { self.managedContext.rx.update($0) }
//      .asDriverOnErrorJustComplete()

    let dismiss = //Driver.of(
     // updateTask.mapToVoid(),
      cancelButtonClickTrigger// )
   //   .merge()
      .do { _ in
        self.steps.accept(AppStep.dismiss)
      }
    
    return Output(
    //  saveImage: saveImage,
     // updateTask: updateTask,
      dismiss: dismiss
    )
  }
}


