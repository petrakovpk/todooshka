//
//  QuestViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 15.05.2023.
//

import CoreData
import RxCocoa
import RxFlow
import RxSwift

class QuestViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  public let quest: Quest
  
  private let services: AppServices
  
  struct Input {
    // header
    let backButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    // header
    let navigateBack: Driver<AppStep>
    // questImageSections
    let questImageSections: Driver<[QuestImageSection]>
    //
    let questPublicationsSections: Driver<[QuestPublicationsSection]>
  }
  
  // MARK: - Init
  init(services: AppServices, quest: Quest) {
    self.services = services
    self.quest = quest
  }
  
  // MARK: - Transform
  func transform(input: Input) -> Output {
    let publications = services.currentUserService.publications
    let publicationImages = services.currentUserService.publicationImages
    
    let quest = services.currentUserService.quests
      .compactMap { quests -> Quest? in
        quests.first { $0.uuid == self.quest.uuid }
      }
      .startWith(self.quest)
    
    let questImages = services.currentUserService.questImages
      .map { questImages -> [QuestImage] in
        questImages
          .filter { questImage -> Bool in
            questImage.questUUID == self.quest.uuid
          }
      }

    let navigateBack = input.backButtonClickTrigger
      .map { _ -> AppStep in
          .navigateBack
      }
      .do { step in
        self.steps.accept(step)
      }
    
    let questImagesItems = questImages
      .map { questImages -> [QuestImageItem] in
        questImages.map { questImage -> QuestImageItem in
            .questImage(questImage: questImage)
        }
      }
        
    let questImageSections = questImagesItems
      .map { items -> [QuestImageSection] in
        [QuestImageSection(header: "", items: items)]
      }
    
    let questPublicationsSections = Driver
      .combineLatest(publications, publicationImages) { publications, publicationImages -> [QuestPublicationsSectionItem] in
        []
//        publications
//          .compactMap { publication -> QuestPublicationsSectionItem? in
//            guard let publicationImage = publicationImages.first { publicationImage in publicationImage.publicationUUID == publication.uuid
//              } else { return nil }
//            return QuestPublicationsSectionItem(publicationImage: publicationImage, publication: publication)
//          }
      }
      .map { items -> [QuestPublicationsSection] in
        [QuestPublicationsSection(header: "", items: items)]
      }
    
   
    return Output(
      // header
      navigateBack: navigateBack,
      // questImageSections
      questImageSections: questImageSections,
      // questPublicationsSections
      questPublicationsSections: questPublicationsSections
    )
  }
}
