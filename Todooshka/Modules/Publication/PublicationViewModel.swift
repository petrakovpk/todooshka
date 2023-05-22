//
//  PublicationViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 07.05.2023.
//

import RxFlow
import RxSwift
import RxCocoa
import UIKit

enum PublicationMode {
  case publication
  case quest
}

class PublicationViewModel: Stepper {
  
  public let steps = PublishRelay<Step>()
  public let publicationMode: PublicationMode
  public var publication: Publication
  
  private let services: AppServices

  struct Input {
    // header
    let backButtonClickTrigger: Driver<Void>
    let moreButtonClickTrigger: Driver<Void>
    // bottom buttons
    let publishButtonClickTrigger: Driver<Void>
  }

  struct Output {
    // header
    let navigateBack: Driver<AppStep>
    let navigateToPublicationSettings: Driver<AppStep>
    let titleHeader: Driver<String>
    // imageView
    let publicKindUIImage: Driver<UIImage?>
    // publication
    let publicationText: Driver<String?>
    let publicationUIImage: Driver<UIImage?>
    // bottom buttons
    let publishButtonIsEnabled: Driver<Bool>
    // save
    let publish: Driver<AppStep>
  }

  // MARK: - Init
  init(services: AppServices, publication: Publication, publicationMode: PublicationMode) {
    self.services = services
    self.publicationMode = publicationMode
    self.publication = publication
  }

  // MARK: - Transform
  func transform(input: Input) -> Output {
    let publications = services.currentUserService.publications
    let publicationImages = services.currentUserService.publicationImages
    
    let publication = publications
      .compactMap { publications -> Publication? in
        publications.first { $0.uuid == self.publication.uuid }
      }
      .startWith(self.publication)
    
    let publicKinds = services.currentUserService.publicKinds
    
    let publicationText = publication
      .map { $0.text }
      .startWith(self.publication.text)
    
    let publicationImage = Driver
      .combineLatest(publication, publicationImages) { publication, publicationImages -> PublicationImage? in
        publicationImages.first { $0.publicationUUID == publication.uuid }
      }
    
    let publicKind = Driver
      .combineLatest(publication, publicKinds) { publication, publicKinds -> PublicKind? in
        publicKinds.first { $0.uuid == publication.publicKindUUID }
      }
    
    let publicKindUIImage = publicKind
      .map { $0?.image }
      
    let publish = input.publishButtonClickTrigger
      .withLatestFrom(publication)
      .map { publication -> Publication in
        var publication = publication
        publication.status = .published
        return publication
      }
      .flatMapLatest { publication -> Driver<Void> in
        StorageManager.shared.managedContext.rx
          .update(publication)
          .asDriverOnErrorJustComplete()
      }
      .map { _ -> AppStep in
          .publicationProcesingIsCompleted
      }
      .do { step in
        self.steps.accept(step)
      }

    let navigateBack = input.backButtonClickTrigger
      .map { _ -> AppStep in
          .publicationProcesingIsCompleted
      }
      .do { step in
        self.steps.accept(step)
      }

    let navigateToPublicationSettings = input.moreButtonClickTrigger
      .withLatestFrom(publication)
      .withLatestFrom(publicationImage) { publication, publicationImage -> AppStep in
          .publicationSettingsIsRequired(
            publication: publication,
            publicationImage: publicationImage
          )
      }
      .do { step in
        self.steps.accept(step)
      }
    
    let titleHeader = publication
      .map { publication -> String in
        publication.status == .unpublished ? "Черновик" : "Опубликовано"
      }

    let publishButtonIsEnabled = publication
      .map { publication -> Bool in
        publication.status == .unpublished
      }

    let publicationUIImage = publicationImage
      .map{ $0?.image }
    
    return Output(
      // header
      navigateBack: navigateBack,
      navigateToPublicationSettings: navigateToPublicationSettings,
      titleHeader: titleHeader,
      publicKindUIImage: publicKindUIImage,
      // publication
      publicationText: publicationText,
      publicationUIImage: publicationUIImage,
      // bottom buttons
      publishButtonIsEnabled: publishButtonIsEnabled,
      // status
      publish: publish
    )
  }
}
