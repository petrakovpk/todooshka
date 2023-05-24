//
//  QuestCreateFirstStepViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 13.05.2023.
//

import CoreData
import RxCocoa
import RxFlow
import RxSwift

class QuestEditPreviewViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  public let quest: Quest
  
  private let services: AppServices

  struct Input {
    // header
    let backButtonClickTrigger: Driver<Void>
    // image
    let questImageClickTrigger: Driver<Void>
    // quest category
    let questCategorySelection: Driver<IndexPath>
  }

  struct Output {
    // header
    let navigateBack: Driver<AppStep>
    // image
    let previewImage: Driver<UIImage?>
    let previewText: Driver<String>
    let openImagePickerIsRequired: Driver<AppStep>
    // quest category
    let questCategorySections: Driver<[PublicKindSection]>
    let saveQuestCategory: Driver<Void>
  }

  // MARK: - Init
  init(services: AppServices, quest: Quest) {
    self.services = services
    self.quest = quest
  }

  // MARK: - Transform
  func transform(input: Input) -> Output {
    let publicKinds = services.currentUserService.publicKinds
    
    let quest = services.currentUserService.quests
      .map { quests -> Quest in
        quests.first { $0.uuid == self.quest.uuid } ?? self.quest
      }
      .debug()
    
    let previewImage = quest
      .map { $0.previewImage }
      .debug()
    
    let previewText = quest
      .map { $0.name }
    
    let questCategoryType = quest
      .withLatestFrom(publicKinds) { quest, publicKinds -> PublicKindItemType in
        if let publicKind = publicKinds.first { $0.uuid == quest.categoryUUID } {
          return .kind(kind: publicKind)
        } else {
          return .empty
        }
      }

    let questCategoryEmptyItem = quest
      .map { quest -> PublicKindItem in
        PublicKindItem(
          publicKindItemType: .empty,
          isSelected: quest.categoryUUID == nil
        )
      }
    
    let questCategoryItems = Driver.combineLatest(publicKinds, quest) { questCategories, quest -> [PublicKindItem] in
      questCategories.map { questCategory -> PublicKindItem in
        PublicKindItem(
          publicKindItemType: .kind(kind: questCategory),
          isSelected: quest.categoryUUID == questCategory.uuid
        )
      }
    }
    
    let questCategorySections = Driver
      .combineLatest(questCategoryEmptyItem, questCategoryItems) { questCategoryEmptyItem, questCategoryItems -> [PublicKindItem] in
        [questCategoryEmptyItem] + questCategoryItems
      }
      .map { items -> [PublicKindSection] in
        [PublicKindSection(header: "", items: items)]
      }
    
    let saveQuestCategory = input.questCategorySelection
      .withLatestFrom(questCategorySections) { indexPath, questCategorySections -> PublicKindItem in
        questCategorySections[indexPath.section].items[indexPath.item]
      }
      .withLatestFrom(quest) { item, quest -> Quest in
        var quest = quest
        switch item.publicKindItemType {
        case .empty:
          quest.categoryUUID = nil
        case .kind(kind: let questCategory):
          quest.categoryUUID = questCategory.uuid
        }
        return quest
      }
      .flatMapLatest { quest -> Driver<Void> in
        StorageManager.shared.managedContext.rx
          .update(quest)
          .asDriverOnErrorJustComplete()
      }

    let navigateBack = input.backButtonClickTrigger
      .map { _ -> AppStep in
          .questPreviewProcessingIsCompleted
      }
      .do { step in
        self.steps.accept(step)
      }
    
    let openImagePickerIsRequired = input.questImageClickTrigger
      .withLatestFrom(quest)
      .map { quest -> AppStep in
          .questPreviewImagePresentationIsRequired(quest: quest)
      }
      .do { step in
        self.steps.accept(step)
      }
    
    return Output(
      // header
      navigateBack: navigateBack,
      // image
      previewImage: previewImage,
      previewText: previewText,
      openImagePickerIsRequired: openImagePickerIsRequired,
      // quest category
      questCategorySections: questCategorySections,
      saveQuestCategory: saveQuestCategory
    )
  }
}
