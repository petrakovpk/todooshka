//
//  QuestImagePresentationViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 11.05.2023.
//

import RxCocoa
import RxFlow
import RxSwift
import UIKit

class QuestImagePresentationViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  
  private let services: AppServices
  private let disposeBag = DisposeBag()
  private let quest: Quest
  
  struct Input {
    let selection: Driver<IndexPath>
  }
  
  struct Output {
    let sections: Driver<[SettingSection]>
    let selectionHandler: Driver<AppStep>
  }
  
  // MARK: - Init
  init(services: AppServices, quest: Quest) {
    self.services = services
    self.quest = quest
  }
  
  func transform(input: Input) -> Output {
    let errorTracker = ErrorTracker()
    
    let currentUser = services.currentUserService.user
    let currentUserExtData = services.currentUserService.extUserData
   // let questImages = services.currentUserService.questImages
    
    let sections = Driver<[SettingSection]>.just([
      SettingSection(header: "Добавить изображение", items: [
        SettingItem(text: "Выбрать из библиотеки", type: .photo),
        SettingItem(text: "Открыть камеру", type: .camera)
      ])
    ])

    let selection = input.selection
      .withLatestFrom(sections) { indexPath, sections -> SettingItem in
        sections[indexPath.section].items[indexPath.item]
      }
    
    let selectionHandler = selection
      .compactMap { item -> AppStep? in
        switch item.type {
        case .camera:
          return .questOpenCameraIsRequired(quest: self.quest)
        case .photo:
          return .questOpenPhotoLibraryIsRequired(quest: self.quest)
        default:
          return nil
        }
      }
      .do { step in
        self.steps.accept(step)
      }
    
    return Output(
      sections: sections,
      selectionHandler: selectionHandler
    )
  }
}
