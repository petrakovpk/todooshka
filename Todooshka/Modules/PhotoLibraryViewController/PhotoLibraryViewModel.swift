//
//  PhotoLibraryViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 05.05.2023.
//

import AnyImageKit
import RxFlow
import RxSwift
import RxCocoa

enum PhotoLibraryPickerResult {
  case publicationImage(publicationImage: PublicationImage)
  case questPreviewImage(quest: Quest)
  case questAuthorImages(questImages: [QuestImage])
  case userExtData(userExtData: UserExtData)
}

class PhotoLibraryViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  
  public let didFinishPickingResult = PublishRelay<AnyImageKit.PickerResult>()
  
  private let services: AppServices
  private let imagePickerMode: ImagePickerMode
  
  struct Input {
    
  }
  
  struct Output {
    let saveImage: Driver<Void>
  }
  
  // MARK: - Init
  init(services: AppServices, imagePickerMode: ImagePickerMode) {
    self.services = services
    self.imagePickerMode = imagePickerMode
  }
  
  // MARK: - Transform
  func transform(input: Input) -> Output {
    let currentUserExtData = services.currentUserService.extUserData
      .compactMap { $0 }
    
    let didFinishPickingResult = didFinishPickingResult.asDriverOnErrorJustComplete()
    
    let images = didFinishPickingResult
      .map { result -> [UIImage] in
        result.assets
          .compactMap { asset -> UIImage? in
            asset.image
          }
      }
    
    let photoLibraryPickerResult = images
      .map { images -> PhotoLibraryPickerResult in
        switch self.imagePickerMode {
        case .publication(let publication):
          return .publicationImage(
            publicationImage: images.map { image -> PublicationImage in
              PublicationImage(uuid: UUID(), publicationUUID: publication.uuid, image: image)
            }.first!
          )
          
        case .questAuthorImages(let quest):
          return .questAuthorImages(
            questImages: images.map { image -> QuestImage in
              QuestImage(uuid: UUID(), questUUID: quest.uuid, image: image)
            }
          )
          
        case .questPreviewImage(var quest):
          quest.previewImage = images.first
          return .questPreviewImage(quest: quest)
          
        case .userExtData(var userExtData):
          userExtData.image = images.first
          return .userExtData(userExtData: userExtData)
        }
      }
    
    let saveImage = photoLibraryPickerResult
      .flatMapLatest { photoLibraryResult -> Driver<Void> in
        switch photoLibraryResult {
        case .publicationImage(let publicationImage):
          self.services.temporaryDataService.temporaryPublicationImage.accept(publicationImage)
          return Driver<Void>.empty()
        case .questAuthorImages(let questImages):
          return StorageManager.shared.managedContext.rx.batchUpdate(questImages).asDriverOnErrorJustComplete()
        case .questPreviewImage(let quest):
          return StorageManager.shared.managedContext.rx.update(quest).asDriverOnErrorJustComplete()
        case .userExtData(let userExtData):
          return StorageManager.shared.managedContext.rx.update(userExtData).asDriverOnErrorJustComplete()
        }
      }
    
    return Output(
      saveImage: saveImage
    )
  }
}
