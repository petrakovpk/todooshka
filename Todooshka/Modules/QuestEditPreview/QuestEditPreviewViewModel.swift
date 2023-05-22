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
    // text
    let questNameTextField: Driver<String>
    let questNameSaveButtonClickTrigger: Driver<Void>
    // quest category
    let questCategorySelection: Driver<IndexPath>
  }

  struct Output {
    // header
    let navigateBack: Driver<AppStep>
    // name
    let saveQuestName: Driver<Void>
    let saveQuestNameButtonIsHidden: Driver<Bool>
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
    let questCategories = services.currentUserService.publicKinds
    
    let quest = services.currentUserService.quests
      .compactMap { quests -> Quest? in
        quests.first { $0.uuid == self.quest.uuid }
      }
      .startWith(self.quest)
    
   
    let questCategoryType = quest
      .withLatestFrom(questCategories) { quest, questCategories -> PublicKindItemType in
        if let questCategory = questCategories.first { $0.uuid == quest.categoryUUID } {
          return .kind(kind: questCategory)
        } else {
          return .empty
        }
      }
      .startWith(.empty)

    let questCategoryEmptyItem = quest
      .map { quest -> PublicKindItem in
        PublicKindItem(
          publicKindItemType: .empty,
          isSelected: quest.categoryUUID == nil
        )
      }
    
    let questCategoryItems = Driver.combineLatest(questCategories, quest) { questCategories, quest -> [PublicKindItem] in
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
          .navigateBack
      }
      .do { step in
        self.steps.accept(step)
      }
    
    let saveQuestName = input.questNameSaveButtonClickTrigger
      .withLatestFrom(input.questNameTextField)
      .withLatestFrom(quest) { name, quest -> Quest in
        var quest = quest
        quest.name = name
        return quest
      }
      .flatMapLatest { quest -> Driver<Void> in
        StorageManager.shared.managedContext.rx
          .update(quest)
          .asDriverOnErrorJustComplete()
      }
    
    let saveQuestNameButtonIsHidden = Driver
      .combineLatest(input.questNameTextField, quest) { name, quest -> Bool in
        quest.name == name
      }
    
    return Output(
      // header
      navigateBack: navigateBack,
      // text
      saveQuestName: saveQuestName,
      saveQuestNameButtonIsHidden: saveQuestNameButtonIsHidden,
      // quest category
      questCategorySections: questCategorySections,
      saveQuestCategory: saveQuestCategory
    )
  }
}
