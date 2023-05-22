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

class CameraPickerViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  
  public let didFinishCapturing = PublishRelay<AnyImageKit.CaptureResult>()
  
  private let services: AppServices
  private let imagePickerMode: ImagePickerMode
  
  struct Input {
   
  }

  struct Output {
    let savePublicationImage: Driver<PublicationImage>
    let saveQuestImage: Driver<Void>
    let saveExtUserDataImage: Driver<Void>
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
    
    let savePublicationImage = didFinishCapturing
      .compactMap { result -> PublicationImage? in
        guard
          result.type == .photo,
          case .publication(let publication) = self.imagePickerMode,
          let imageData = try? Data(contentsOf: result.mediaURL),
          let image = UIImage(data: imageData)
        else {
          return nil
        }

        return PublicationImage(uuid: UUID(), publicationUUID: publication.uuid, image: image)
      }
      .do { publicationImage in
        self.services.temporaryDataService.temporaryPublicationImage.accept(publicationImage)
      }
    
    let saveQuestImage = didFinishCapturing
      .compactMap { result -> QuestImage? in
        guard
          result.type == .photo,
          case .quest(let quest) = self.imagePickerMode,
          let imageData = try? Data(contentsOf: result.mediaURL),
          let image = UIImage(data: imageData)
        else {
          return nil
        }

        return QuestImage(uuid: UUID(), questUUID: quest.uuid, image: image)
      }
      .flatMapLatest { questImage -> Driver<Void> in
        StorageManager.shared.managedContext.rx
          .update(questImage)
          .asDriverOnErrorJustComplete()
      }

    let saveExtUserDataImage = didFinishCapturing
      .compactMap { result -> UserExtData? in
        guard
          result.type == .photo,
          case .userProfile(var extUserData) = self.imagePickerMode,
          let imageData = try? Data(contentsOf: result.mediaURL),
          let image = UIImage(data: imageData)
        else {
          return nil
        }
        extUserData.image = image
        return extUserData
      }
      .flatMapLatest { extUserData -> Driver<Void> in
        StorageManager.shared.managedContext.rx
          .update(extUserData)
          .asDriverOnErrorJustComplete()
      }
    
    return Output(
      savePublicationImage: savePublicationImage,
      saveQuestImage: saveQuestImage,
      saveExtUserDataImage: saveExtUserDataImage
    )
  }
}

