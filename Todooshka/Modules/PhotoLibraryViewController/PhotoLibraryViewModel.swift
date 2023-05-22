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

class PhotoLibraryViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  
  public let didFinishPickingResult = PublishRelay<AnyImageKit.PickerResult>()
  
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
    
    let didFinishPickingResult = didFinishPickingResult.asDriverOnErrorJustComplete()
    
    let savePublicationImage = didFinishPickingResult
      .map { result -> [PublicationImage] in
        result.assets.compactMap { asset -> PublicationImage? in
          switch self.imagePickerMode {
          case .publication(let publication):
            return PublicationImage(uuid: UUID(), publicationUUID: publication.uuid, image: asset.image)
          default:
            return nil
          }
        }
      }
      .compactMap { publicationImages -> PublicationImage? in
        publicationImages.first
      }
      .do { publicationImage in
        self.services.temporaryDataService.temporaryPublicationImage.accept(publicationImage)
      }

    
    let saveQuestImage = didFinishPickingResult
      .map { result -> [QuestImage] in
        result.assets.compactMap { asset -> QuestImage? in
          switch self.imagePickerMode {
          case .quest(let quest):
            return QuestImage(uuid: UUID(), questUUID: quest.uuid, image: asset.image)
          default:
            return nil
          }
        }
      }
      .flatMapLatest { questImages -> Driver<Void> in
        StorageManager.shared.managedContext.rx
          .batchUpdate(questImages)
          .asDriverOnErrorJustComplete()
      }
    
    let saveExtUserDataImage = didFinishPickingResult
      .map { result -> [UserExtData] in
        result.assets.compactMap { asset -> UserExtData? in
          switch self.imagePickerMode {
          case .userProfile(var extUserData):
            extUserData.image = asset.image
            return extUserData
          default:
            return nil
          }
        }
      }
      .flatMapLatest { userExtDatas -> Driver<Void> in
        StorageManager.shared.managedContext.rx
          .batchUpdate(userExtDatas)
          .asDriverOnErrorJustComplete()
      }
    
    return Output(
      savePublicationImage: savePublicationImage,
      saveQuestImage: saveQuestImage,
      saveExtUserDataImage: saveExtUserDataImage
    )
  }
}
