//
//  QuestCreateImagePreviewViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 14.05.2023.
//

import CoreData
import RxCocoa
import RxFlow
import RxSwift

class QuestGalleryViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  public let quest: Quest
  
  private let questImage: QuestImage
  private let services: AppServices

  struct Input {
    // header
    let backButtonClickTrigger: Driver<Void>
    // collectionView
    let willDisplayCell: Driver<Reactive<UICollectionView>.DisplayCollectionViewCellEvent>
    // remove
    let removeButtonClickTrigger: Driver<Void>
  }

  struct Output {
    // header
    let navigateBack: Driver<AppStep>
    // quest gallery
    let questImageSections: Driver<[QuestImageSection]>
    let scrollToImage: Driver<IndexPath>
    // remove
    let removeImage: Driver<Void>
  }

  // MARK: - Init
  init(services: AppServices, quest: Quest, questImage: QuestImage) {
    self.services = services
    self.quest = quest
    self.questImage = questImage
  }

  // MARK: - Transform
  func transform(input: Input) -> Output {
    
    let questImages = services.currentUserService.questImages
      .map { questImages -> [QuestImage] in
        questImages
          .filter { questImage -> Bool in
            questImage.questUUID == self.quest.uuid
          }
      }
    
    let questImagesItems = questImages
      .map { questImages -> [QuestImageItem] in
        questImages.map { questImage -> QuestImageItem in
            .questImage(questImage: questImage)
        }
      }
    
    let questImageSections = questImagesItems
      .map { questImagesItems -> [QuestImageSection] in
        [QuestImageSection(header: "", items: questImagesItems)]
      }
    
    let scrollToImage = questImageSections
      .compactMap { sections -> IndexPath? in
        guard
          let itemIndex = sections
            .first?.items
            .firstIndex(where: { questImageItem in
              questImageItem == .questImage(questImage: self.questImage)
            })
        else {
          return nil
        }
        
        return IndexPath(item: itemIndex, section: 0)
      }
    
    let removeImage = input.removeButtonClickTrigger
      .withLatestFrom( input.willDisplayCell)
      .withLatestFrom(questImageSections) { event, sections -> QuestImageItem in
        sections[event.at.section].items[event.at.item]
      }
      .compactMap { questImageItem -> QuestImage? in
        guard case .questImage(let questImage) = questImageItem else { return nil }
        return questImage
      }
      .flatMapLatest { questImage -> Driver<Void> in
        StorageManager.shared.managedContext.rx
          .delete(questImage)
          .asDriverOnErrorJustComplete()
      }
    
    let navigateBack = input.backButtonClickTrigger
      .map { _ -> AppStep in
          .dismiss
      }
      .do { step in
        self.steps.accept(step)
      }
    
    return Output(
      // header
      navigateBack: navigateBack,
      // questImageSections
      questImageSections: questImageSections,
      scrollToImage: scrollToImage,
      // remove
      removeImage: removeImage
    )
  }
}

