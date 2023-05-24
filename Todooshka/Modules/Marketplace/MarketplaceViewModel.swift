//
//  MarketplaceViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 31.10.2022.
//

import Firebase
import RxFlow
import RxSwift
import RxCocoa

class MarketplaceViewModel: Stepper {
  let services: AppServices
  let steps = PublishRelay<Step>()

  struct Input {
    // auth
    let authButtonClickTrigger: Driver<Void>
    // create
    let createQuestButtonClickTrigger: Driver<Void>
    let selection: Driver<IndexPath>
  }
  
  struct Output {
    // auth
    let auth: Driver<AppStep>
    // add
    let addButtonIsHidden: Driver<Bool>
    // pleaseAuthContainerViewIsHidden
    let pleaseAuthContainerViewIsHidden: Driver<Bool>
    // marketplace
    let marketplaceQuestSections: Driver<[MarketplaceQuestSection]>
    // selection
    let openQuest: Driver<AppStep>
    let createQuest: Driver<AppStep>
    let editQuest: Driver<AppStep>
    
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {
    let currentUser = services.currentUserService.user
    let quests = services.currentUserService.quests
    let questImages = services.currentUserService.questImages
  
    let pleaseAuthContainerViewIsHidden = currentUser
      .map { $0 != nil }

    let addButtonIsHidden = pleaseAuthContainerViewIsHidden
      .map { !$0 }
    
    let auth = input.authButtonClickTrigger
      .map { _ -> AppStep in
          .authIsRequired
      }
      .do { step in
        self.steps.accept(step)
      }
    
    let createQuest = input.createQuestButtonClickTrigger
      .map { _ -> AppStep in
          .questEditIsRequired(quest: Quest(uuid: UUID(), status: .draft))
      }
      .do { step in
        self.steps.accept(step)
      }
    
    let marketplaceDraftQuestSection = quests
      .withLatestFrom(questImages) { quests, questImages -> [MarketplaceQuestSectionItem] in
        quests
          .filter { quest -> Bool in
            quest.status == .draft
          }
          .map { quest -> MarketplaceQuestSectionItem in
            MarketplaceQuestSectionItem(
              quest: quest,
              image: questImages
                .first {
                  $0.questUUID == quest.uuid }?.image ?? UIImage()
            )
          }
      }
      .map { items -> MarketplaceQuestSection in
        MarketplaceQuestSection(
          header: "Ваши задачи:",
          type: .personal,
          items: items)
      }
    
    let marketplaceRecommendedQuestSection = quests
      .withLatestFrom(questImages) { quests, questImages -> [MarketplaceQuestSectionItem] in
        quests
          .filter { quest -> Bool in
            quest.status == .draft
          }
          .map { quest -> MarketplaceQuestSectionItem in
            MarketplaceQuestSectionItem(
              quest: quest,
              image: questImages
                .first {
                  $0.questUUID == quest.uuid }?.image ?? UIImage()
            )
          }
      }
      .map { items -> MarketplaceQuestSection in
        MarketplaceQuestSection(
          header: "Рекомендумое:",
          type: .recommended,
          items: items)
      }
    
    let marketplaceQuestSections = Driver
      .combineLatest(marketplaceDraftQuestSection, marketplaceRecommendedQuestSection) { draft, recommended -> [MarketplaceQuestSection] in
        [draft] + [recommended]
      }
      .compactMap { sections -> [MarketplaceQuestSection] in
        sections.filter { !$0.items.isEmpty }
      }
    
    let editQuest = input.selection
      .withLatestFrom(marketplaceQuestSections) { indexPath, sections -> (section: MarketplaceQuestSection, item: MarketplaceQuestSectionItem) in
        (sections[indexPath.section], sections[indexPath.section].items[indexPath.item])
      }
      .filter { (section, item) in
        section.type == .personal
      }
      .map { (section, item) -> Quest in
        item.quest
      }
      .map { quest -> AppStep in
          .questEditIsRequired(quest: quest)
      }
      .do { step in
        self.steps.accept(step)
      }
    
    let openQuest = input.selection
      .withLatestFrom(marketplaceQuestSections) { indexPath, sections -> (section: MarketplaceQuestSection, item: MarketplaceQuestSectionItem) in
        (sections[indexPath.section], sections[indexPath.section].items[indexPath.item])
      }
      .filter { (section, item) in
        section.type != .personal
      }
      .map { (section, item) -> Quest in
        item.quest
      }
      .map { quest -> AppStep in
          .questIsRequired(quest: quest)
      }
      .do { step in
        self.steps.accept(step)
      }

    
    return Output(
      auth: auth,
      // hrader
      addButtonIsHidden: addButtonIsHidden,
      // pleaseAuthContainerViewIsHidden
      pleaseAuthContainerViewIsHidden: pleaseAuthContainerViewIsHidden,
      // marketplace
      marketplaceQuestSections: marketplaceQuestSections,
      // selection
      openQuest: openQuest,
      createQuest: createQuest,
      editQuest: editQuest
    )
  }
}
