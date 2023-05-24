//
//  ExtPhotoPickerViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 06.05.2023.
//

import AnyImageKit
import RxFlow
import RxSwift
import RxCocoa

enum CameraPickerResult {
  case publicationImage(publicationImage: PublicationImage)
  case questPreviewImage(quest: Quest)
  case questAuthorImages(questImages: QuestImage)
  case userExtData(userExtData: UserExtData)
}

class CameraPickerViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  
  public let didFinishCapturing = PublishRelay<AnyImageKit.CaptureResult>()
  
  private let services: AppServices
  private let imagePickerMode: ImagePickerMode
  
  struct Input {
   
  }

  struct Output {
    let savePhoto: Driver<Void>
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
    
    let didFinishCapturing = didFinishCapturing.asDriverOnErrorJustComplete()
    
    let image = didFinishCapturing
      .compactMap { result -> UIImage? in
        guard let imageData = try? Data(contentsOf: result.mediaURL),
              let image = UIImage(data: imageData) else { return nil }
        return image
      }
    
    let imagePickerResult = image
      .map { image -> CameraPickerResult in
        switch self.imagePickerMode {
        case .publication(let publication):
          return .publicationImage(
            publicationImage: PublicationImage(uuid: UUID(), publicationUUID: publication.uuid, image: image)
          )
          
        case .questAuthorImages(let quest):
          return .questAuthorImages(
            questImages: QuestImage(uuid: UUID(), questUUID: quest.uuid, image: image)
          )
          
        case .questPreviewImage(var quest):
          quest.previewImage = image
          return .questPreviewImage(quest: quest)
          
        case .userExtData(var userExtData):
          userExtData.image = image
          return .userExtData(userExtData: userExtData)
        }
      }
    
    let savePhoto = imagePickerResult
      .flatMapLatest { photoLibraryResult -> Driver<Void> in
        switch photoLibraryResult {
        case .publicationImage(let publicationImage):
          self.services.temporaryDataService.temporaryPublicationImage.accept(publicationImage)
          return Driver<Void>.empty()
        case .questAuthorImages(let questImage):
          return StorageManager.shared.managedContext.rx.update(questImage).asDriverOnErrorJustComplete()
        case .questPreviewImage(let quest):
          return StorageManager.shared.managedContext.rx.update(quest).asDriverOnErrorJustComplete()
        case .userExtData(let userExtData):
          return StorageManager.shared.managedContext.rx.update(userExtData).asDriverOnErrorJustComplete()
        }
      }

    return Output(
      savePhoto: savePhoto
    )
  }
}

