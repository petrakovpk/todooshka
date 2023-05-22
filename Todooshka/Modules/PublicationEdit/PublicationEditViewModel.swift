//
//  PublicationEditViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 19.05.2023.
//

import RxFlow
import RxSwift
import RxCocoa
import UIKit

class PublicationEditViewModel: Stepper {
  
  public let steps = PublishRelay<Step>()

  private let services: AppServices
  
  struct Input {
    // header
    let backButtonClickTrigger: Driver<Void>
    // text
    let publicationTextView: Driver<String?>
    // kind
    let publicKindClickTrigger: Driver<Void>
    // bottom buttons
    let photoLibraryButtonClickTrigger: Driver<Void>
    let cameraButtonClickTrigger: Driver<Void>
    let clearButtonClickTrigger: Driver<Void>
    let saveButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    // header
    let navigateBack: Driver<AppStep>
    let openPublicKind: Driver<AppStep>
    // imageView
    let publicKindUIImage: Driver<UIImage?>
    // publication
    let publicationText: Driver<String?>
    let publicationUIImage: Driver<UIImage?>
    let publicationClearImage: Driver<Void>
    let publicationOpenCamera: Driver<AppStep>
    let publicationOpenPhotoLibrary: Driver<AppStep>
    let publicationClearImageButtonIsHidden: Driver<Bool>
    let publicationAddImageButtonsIsHidden: Driver<Bool>
    // save
    let publicationSaveToCoreData: Driver<Void>
    let publicationImageSaveToCoreData: Driver<Void>
  }
  
  // MARK: - Init
  init(services: AppServices, publication: Publication, publicationImage: PublicationImage?) {
    self.services = services
    self.services.temporaryDataService.temporaryPublication.accept(publication)
    self.services.temporaryDataService.temporaryPublicationImage.accept(publicationImage)
  }
  
  // MARK: - Transform
  func transform(input: Input) -> Output {
    let publication = services.temporaryDataService
      .temporaryPublication
      .asDriver()
      .compactMap { $0 }
      .debug()
    
    let publicationImage = services.temporaryDataService
      .temporaryPublicationImage
      .asDriver()
    
    let publicKinds = services.currentUserService.publicKinds
    
    let publicKind = Driver
      .combineLatest(publication, publicKinds) { publication, publicKinds -> PublicKind? in
        publicKinds.first { $0.uuid == publication.publicKindUUID }
    }
      .debug()
        
    let publicationText = publication
      .map { $0.text }
    
    let publicKindUIImage = publicKind
      .map { publicKind -> UIImage? in
        publicKind?.image
      }
    
    let publicationUIImage = publicationImage
      .map { $0?.image }
      .debug()
    
    let publicationClearImageButtonIsHidden = publicationUIImage
      .map { $0 == nil }
    
    let publicationAddImageButtonsIsHidden = publicationClearImageButtonIsHidden
      .map { !$0 }
    
    let publicationClearImage = input.clearButtonClickTrigger
      .do { _ in
        self.services.temporaryDataService.temporaryPublicationImage.accept(nil)
      }
    
    let publicationOpenPhotoLibrary = input.photoLibraryButtonClickTrigger
      .withLatestFrom(publication)
      .map { publication -> AppStep in
          .publicationPhotoLibraryIsRequired(publication: publication)
      }
      .do { step in
        self.steps.accept(step)
      }
    
    let publicationOpenCamera = input.cameraButtonClickTrigger
      .withLatestFrom(publication)
      .map { publication -> AppStep in
          .publicationCameraIsRequired(publication: publication)
      }
      .do { step in
        self.steps.accept(step)
      }

    let publicationSaveToCoreData = input.saveButtonClickTrigger
      .withLatestFrom(input.publicationTextView)
      .withLatestFrom(publication) { text, publication -> Publication in
        var publication = publication
        publication.text = text
        return publication
      }
      .flatMapLatest { publication -> Driver<Void> in
        StorageManager.shared.managedContext.rx.update(publication).asDriverOnErrorJustComplete()
      }

    let publicationImageSaveToCoreData = input.saveButtonClickTrigger
      .withLatestFrom(publicationImage)
      .flatMapLatest { publicationImage -> Driver<Void> in
        if let publicationImage = publicationImage {
          return StorageManager.shared.managedContext.rx.update(publicationImage).asDriverOnErrorJustComplete()
        } else if let publicationImage = publicationImage {
          return StorageManager.shared.managedContext.rx.delete(publicationImage).asDriverOnErrorJustComplete()
        } else {
          return Driver<Void>.just(())
        }
      }
    
    let navigateBack = Driver
      .of(input.backButtonClickTrigger, input.saveButtonClickTrigger)
      .merge()
      .map { _ -> AppStep in
          .publicationEditProcesingIsCompleted
      }
      .do { step in
        self.steps.accept(step)
      }
    
    let openPublicKind = input.publicKindClickTrigger
      .withLatestFrom(publication)
      .map { publication -> AppStep in
          .publicationPublicKindIsRequired(publication: publication)
      }
      .do { step in
        self.steps.accept(step)
      }
    
    return Output(
      // header
      navigateBack: navigateBack,
      openPublicKind: openPublicKind,
      // public kind
      publicKindUIImage: publicKindUIImage,
      // publication
      publicationText: publicationText,
      publicationUIImage: publicationUIImage,
      publicationClearImage: publicationClearImage,
      publicationOpenCamera: publicationOpenCamera,
      publicationOpenPhotoLibrary: publicationOpenPhotoLibrary,
      publicationClearImageButtonIsHidden: publicationClearImageButtonIsHidden,
      publicationAddImageButtonsIsHidden: publicationAddImageButtonsIsHidden,
      // save
      publicationSaveToCoreData: publicationSaveToCoreData,
      publicationImageSaveToCoreData: publicationImageSaveToCoreData
    )
  }
}

