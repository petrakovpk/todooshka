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
    // title
    let titleTextField: Driver<String>
    let titleSaveButtonClickTrigger: Driver<Void>
    // description
    let descriptionTextView: Driver<String>
    let descriptionSaveButtonClickTrigger: Driver<Void>
    // author photo
    let authorImagesSelection: Driver<IndexPath>
    // preview
    let previewButtonClickTrigger: Driver<Void>
    // publish
    let publishButtonClickTrigger: Driver<Void>
  }

  struct Output {
    // header
    let navigateBack: Driver<AppStep>
    let navigateToSettings: Driver<AppStep>
    let navigateToPreview: Driver<AppStep>
    // title
    let titleTextSaveButtonIsHidden: Driver<Bool>
    // description
    let descriptionSaveButtonIsHidden: Driver<Bool>
    // author images
    let authorImagesSections: Driver<[QuestImageSection]>
    let authorImagesAddImage: Driver<AppStep>
    let authorImagesOpenGallery: Driver<AppStep>
    // save
    let saveTitle: Driver<Void>
    let saveDescription: Driver<Void>
    // bottom buttons
    let publishButtonIsEnabled: Driver<Bool>
    let publishQuest: Driver<AppStep>
  }

  // MARK: - Init
  init(services: AppServices, quest: Quest) {
    self.services = services
    self.quest = quest
  }

  // MARK: - Transform
  func transform(input: Input) -> Output {
    // quest
    let quest = services.currentUserService.quests
      .map { quests -> Quest in
        quests.first { $0.uuid == self.quest.uuid } ?? self.quest
      }
    
    let authorImages = services.currentUserService.questImages
      .map { questImages -> [QuestImage] in
        questImages
          .filter { questImage -> Bool in
            questImage.questUUID == self.quest.uuid
          }
      }
    
    // navigation
    let navigateBack = input.backButtonClickTrigger
      .map { _ -> AppStep in
          .navigateBack
      }
      .do { step in
        self.steps.accept(step)
      }
    
    let navigateToSettings = input.moreButtonClickTrigger
      .map { _ -> AppStep in
          .questSettingsPresentationIsRequired(quest: self.quest)
      }
      .do { step in
        self.steps.accept(step)
      }
    
    let navigateToPreview = input.previewButtonClickTrigger
      .map { _ -> AppStep in
          .questPreviewIsRequired(quest: self.quest)
      }
      .do { step in
        self.steps.accept(step)
      }

    // title
    let titleTextSaveButtonIsHidden = Driver
      .combineLatest(quest, input.titleTextField) { quest, title -> Bool in
        quest.name == title
      }
    
    // description
    let descriptionSaveButtonIsHidden = Driver
      .combineLatest(quest, input.descriptionTextView) { quest, description -> Bool in
        quest.description == description
      }
    
    // authorImagesSections
    let authorImagesItems = authorImages
      .map { questImages -> [QuestImageItem] in
        questImages.map { questImage -> QuestImageItem in
            .questImage(questImage: questImage)
        }
      }
    
    let authorImagesAddPhotoItem = Driver<QuestImageItem>.of(.addPhoto)
    
    let authorImagesSections = Driver
      .combineLatest(authorImagesItems, authorImagesAddPhotoItem) { authorImagesItems, addPhotoItem -> QuestImageSection in
        QuestImageSection(header: "", items: authorImagesItems + [addPhotoItem])
      }
      .map { [$0] }
    
    let authorImagesSelectedItem = input.authorImagesSelection
      .withLatestFrom(authorImagesSections) { indexPath, sections -> QuestImageItem in
        sections[indexPath.section].items[indexPath.item]
      }
    
    let authorImagesAddImage = authorImagesSelectedItem
      .filter { item -> Bool in
        item == .addPhoto
      }
      .map { _ -> AppStep in
          .questAuthorImagesPresentationIsRequired(quest: self.quest)
      }
      .do { step in
        self.steps.accept(step)
      }
    
    let authorImagesOpenGallery = authorImagesSelectedItem
      .compactMap { item -> QuestImage? in
        guard case .questImage(let questImage) = item else { return nil }
        return questImage
      }
      .map { questImage -> AppStep in
          .questGalleryIsRequired(quest: self.quest, questImage: questImage)
      }
      .do { step in
        self.steps.accept(step)
      }

    let saveTitle = input.titleSaveButtonClickTrigger
      .withLatestFrom(input.titleTextField)
      .withLatestFrom(quest) { title, quest -> Quest in
        var quest = quest
        quest.name = title
        return quest
      }
      .flatMapLatest { quest -> Driver<Void> in
        StorageManager.shared.managedContext.rx
          .update(quest)
          .asDriverOnErrorJustComplete()
      }
    
    let saveDescription = input.descriptionSaveButtonClickTrigger
      .withLatestFrom(input.descriptionTextView)
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
    
    let publishButtonIsEnabled = quest
      .map { quest -> Bool in
        !quest.name.isEmpty && quest.previewImage != nil
      }
    
    let publishQuest = input.publishButtonClickTrigger
      .withLatestFrom(quest)
      .map { quest -> Quest in
        var quest = quest
        quest.status = .published
        return quest
      }
      .flatMapLatest { quest -> Driver<Void> in
        StorageManager.shared.managedContext.rx.update(quest).asDriverOnErrorJustComplete()
      }
      .map { _ -> AppStep in
          .navigateBack
      }
      .do { step in
        self.steps.accept(step)
      }

    return Output(
      // header
      navigateBack: navigateBack,
      navigateToSettings: navigateToSettings,
      navigateToPreview: navigateToPreview,
      // title
      titleTextSaveButtonIsHidden: titleTextSaveButtonIsHidden,
      // description
      descriptionSaveButtonIsHidden: descriptionSaveButtonIsHidden,
      // author image
      authorImagesSections: authorImagesSections,
      authorImagesAddImage: authorImagesAddImage,
      authorImagesOpenGallery: authorImagesOpenGallery,
      // save
      saveTitle: saveTitle,
      saveDescription: saveDescription,
      // bottom buttons
      publishButtonIsEnabled: publishButtonIsEnabled,
      publishQuest: publishQuest
    )
  }
}
