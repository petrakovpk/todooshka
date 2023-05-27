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
    // search
    let searchBarClickTrigger: Driver<Void>
    // create
    let createQuestButtonClickTrigger: Driver<Void>
    let selection: Driver<IndexPath>
  }
  
  struct Output {
    // auth

    let navigateToQuest: Driver<AppStep>
    let navigateToSearch: Driver<AppStep>

    // marketplace
    let marketplaceQuestSections: Driver<[MarketplaceQuestSection]>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {
    let currentUser = services.currentUserService.user
    let quests = services.currentUserService.quests
    let questImages = services.currentUserService.questImages
  
    // navigate

    
    let navigateToSearch = input.searchBarClickTrigger
      .map { _ -> AppStep in
        .searchIsRequired
      }
      .do { step in
        self.steps.accept(step)
      }
    
    let navigateToCreateQuest = input.createQuestButtonClickTrigger
      .map { _ -> AppStep in
          .questEditIsRequired(quest: Quest(uuid: UUID(), status: .draft))
      }

    // questSections
    let marketplaceDraftQuestSection = quests
      .map { quests -> [MarketplaceQuestSectionItem] in
        quests
          .filter { quest in
            quest.status == .draft
          }
          .map { quest -> MarketplaceQuestSectionItem in
            MarketplaceQuestSectionItem(quest: quest)
          }
      }
      .map { items -> MarketplaceQuestSection in
        MarketplaceQuestSection(
          header: "Черновики:",
          type: .personal,
          items: items)
      }
    
    let marketplacePersonalQuestSection = quests
      .withLatestFrom(currentUser) { quests, currentUser -> [MarketplaceQuestSectionItem] in
        quests
          .filter { quest in
            quest.status == .published && quest.userUID == currentUser?.uid
          }
          .map { quest -> MarketplaceQuestSectionItem in
            MarketplaceQuestSectionItem(quest: quest)
          }
    }
      .map { items -> MarketplaceQuestSection in
        MarketplaceQuestSection(
          header: "Мое опубликованное:",
          type: .personal,
          items: items)
      }
    
    let marketplaceRecommendedQuestSection = quests
      .withLatestFrom(currentUser) { quests, currentUser -> [MarketplaceQuestSectionItem] in
        quests
          .filter { quest in
            quest.status == .published && quest.userUID != currentUser?.uid
          }
          .map { quest -> MarketplaceQuestSectionItem in
            MarketplaceQuestSectionItem(quest: quest)
          }
    }
      .map { items -> MarketplaceQuestSection in
        MarketplaceQuestSection(
          header: "Рекомендованное:",
          type: .recommended,
          items: items)
      }
    
    let marketplaceQuestSections = Driver
      .combineLatest(marketplaceDraftQuestSection, marketplacePersonalQuestSection, marketplaceRecommendedQuestSection) { draft, personal, recommended -> [MarketplaceQuestSection] in
        [draft] + [personal] + [recommended]
      }
      .compactMap { sections -> [MarketplaceQuestSection] in
        sections.filter { !$0.items.isEmpty }
      }
  
    let selectedItem = input.selection
      .withLatestFrom(marketplaceQuestSections) { indexPath, sections -> MarketplaceQuestSectionItem in
        sections[indexPath.section].items[indexPath.item]
      }
    
    let navigateToSelectionQuest = selectedItem
      .compactMap { item -> AppStep? in
        switch item.quest.status {
        case .draft:
          return .questEditIsRequired(quest: item.quest)
        case .published:
          return item.quest.userUID == Auth.auth().currentUser?.uid ? .questEditIsRequired(quest: item.quest) : .questIsRequired(quest: item.quest)
        default:
          return nil
        }
      }

    let navigateToQuest = Driver
      .of(navigateToCreateQuest, navigateToSelectionQuest)
      .merge()
      .do { step in
        self.steps.accept(step)
      }
    
    return Output(
      // navigate
  
      navigateToQuest: navigateToQuest,
      navigateToSearch: navigateToSearch,
      // auth container
    //  
      // marketplace
      marketplaceQuestSections: marketplaceQuestSections
    )
  }
}
