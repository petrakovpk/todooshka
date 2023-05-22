//
//  QuestKindPresentationViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 11.05.2023.
//

import RxCocoa
import RxFlow
import RxSwift
import UIKit

class QuestCategoryPresentationViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  
  private let services: AppServices
  private let disposeBag = DisposeBag()
  private let quest: Quest
  
  struct Input {
    let selection: Driver<IndexPath>
  }
  
  struct Output {
    let questCategorySections: Driver<[PublicKindSection]>
    let saveQuestCategory: Driver<Void>
  }
  
  // MARK: - Init
  init(services: AppServices, quest: Quest) {
    self.services = services
    self.quest = quest
  }
  
  func transform(input: Input) -> Output {
    let errorTracker = ErrorTracker()
    
    let questCategories = services.currentUserService.publicKinds
    let quest = services.currentUserService.quests
      .compactMap { quests -> Quest? in
        quests.first { $0.uuid == self.quest.uuid }
      }
      .debug()
      .startWith(self.quest)
    
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
    
    let saveQuestCategory = input.selection
      .withLatestFrom(questCategorySections) { indexPath, questCategorySections -> PublicKindItem in
        questCategorySections[indexPath.section].items[indexPath.item]
      }
      .withLatestFrom(quest) { item, quest -> Quest in
        var quest = quest
        switch item.publicKindItemType {
        case .empty:
          quest.categoryUUID = nil
        case .kind(kind: let kind):
          quest.categoryUUID = kind.uuid
        }
        return quest
      }
      .flatMapLatest { quest -> Driver<Void> in
        StorageManager.shared.managedContext.rx
          .update(quest)
          .asDriverOnErrorJustComplete()
      }

    return Output(
      questCategorySections: questCategorySections,
      saveQuestCategory: saveQuestCategory
    )
  }
}

