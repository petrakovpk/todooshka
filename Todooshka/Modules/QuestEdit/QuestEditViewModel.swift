//
//  ThemeViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 07.11.2022.
//

import CoreData
import RxCocoa
import RxFlow
import RxSwift

class QuestEditViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  public let quest: Quest
  
  private let services: AppServices

  struct Input {
    // header
    let backButtonClickTrigger: Driver<Void>
    let moreButtonClickTrigger: Driver<Void>
    // cover image
    let coverImageViewClickTrigger: Driver<Void>
    // description
    let questDescriptionTextView: Driver<String>
    let saveDescriptionButtonClickTrigger: Driver<Void>
    // author photo
    let questImagesSelection: Driver<IndexPath>
  }

  struct Output {
    // header
    let navigateBack: Driver<AppStep>
    let navigateToSettings: Driver<AppStep>
    // coer
    let openExtra: Driver<AppStep>
    // quest image
    let questImageSections: Driver<[QuestImageSection]>
    let addQuestImage: Driver<AppStep>
    let openGallery: Driver<AppStep>
    // name
    let questName: Driver<String>
    // description
    let saveDescription: Driver<Void>
    let saveDescriptionButtonIsHidden: Driver<Bool>
    // bottom buttons
    let publishButtonIsEnabled: Driver<Bool>
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
    
    let questImages = services.currentUserService.questImages
      .map { questImages -> [QuestImage] in
        questImages
          .filter { questImage -> Bool in
            questImage.questUUID == self.quest.uuid
          }
      }
    
    let openExtra = input.coverImageViewClickTrigger
      .map { _ -> AppStep in
          .questEditPreviewIsRequired(quest: self.quest)
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
    
    let questImagesAddPhotoItem = Driver<QuestImageItem>.of(.addPhoto)
    
    let questImageSections = Driver
      .combineLatest(questImagesItems, questImagesAddPhotoItem) { questImagesItems, addPhotoItem -> QuestImageSection in
        QuestImageSection(header: "", items: questImagesItems + [addPhotoItem])
      }
      .map { [$0] }
    
    let questImageItemSelected = input.questImagesSelection
      .withLatestFrom(questImageSections) { indexPath, sections -> QuestImageItem in
        sections[indexPath.section].items[indexPath.item]
      }
    
    let addQuestImage = questImageItemSelected
      .filter { item -> Bool in
        item == .addPhoto
      }
      .map { _ -> AppStep in
          .questOpenAddImagePresentationIsRequired(quest: self.quest)
      }
      .do { step in
        self.steps.accept(step)
      }
    
    let openGallery = questImageItemSelected
      .compactMap { item -> QuestImage? in
        guard case .questImage(let questImage) = item else { return nil }
        return questImage
      }
      .map { questImage -> AppStep in
          .questGalleryOpenIsRequired(quest: self.quest, questImage: questImage)
      }
      .do { step in
        self.steps.accept(step)
      }
    

    let navigateBack = input.backButtonClickTrigger
      .map { _ -> AppStep in
          .navigateBack
      }
      .do { step in
        self.steps.accept(step)
      }
    
    let navigateToSettings = input.moreButtonClickTrigger
      .map { _ -> AppStep in
          .questPresentationIsRequired(quest: self.quest)
      }
      .do { step in
        self.steps.accept(step)
      }
    
    let publishButtonIsEnabled = input.questDescriptionTextView
      .map { !$0.isEmpty }
    
    let saveDescription = input.saveDescriptionButtonClickTrigger
      .withLatestFrom(input.questDescriptionTextView)
      .withLatestFrom(quest) { description, quest -> Quest in
        var quest = quest
        quest.description = description
        return quest
      }
      .flatMapLatest { quest -> Driver<Void> in
        StorageManager.shared.managedContext.rx
          .update(quest)
          .asDriverOnErrorJustComplete()
      }
    
    let saveDescriptionButtonIsHidden = Driver
      .combineLatest(input.questDescriptionTextView, quest) { description, quest -> Bool in
        quest.description == description
      }
    
    let questName = quest
      .map { quest -> String in
        quest.name
      }
    
    return Output(
      // header
      navigateBack: navigateBack,
      navigateToSettings: navigateToSettings,
      // cover
      openExtra: openExtra,
      // quest image
      questImageSections: questImageSections,
      addQuestImage: addQuestImage,
      openGallery: openGallery,
      // name
      questName: questName,
      // description
      saveDescription: saveDescription,
      saveDescriptionButtonIsHidden: saveDescriptionButtonIsHidden,
      // bottom buttons
      publishButtonIsEnabled: publishButtonIsEnabled
    )
  }
}
