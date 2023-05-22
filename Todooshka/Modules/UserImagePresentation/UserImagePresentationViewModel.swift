//
//  AddAvatarViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 04.05.2023.
//

import RxCocoa
import RxFlow
import RxSwift
import UIKit

class UserImagePresentationViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  
  private let services: AppServices
  private let disposeBag = DisposeBag()
  
  struct Input {
    let avatarClickTrigger: Driver<Void>
    let selection: Driver<IndexPath>
  }
  
  struct Output {
    let userExtDataImage: Driver<UIImage?>
    let sections: Driver<[SettingSection]>
    let selectionHandler: Driver<AppStep>
  }
  
  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  func transform(input: Input) -> Output {
    let errorTracker = ErrorTracker()
    
    let currentUser = services.currentUserService.user
    let userExtData = services.currentUserService.extUserData
      .compactMap { $0 }
    
    let userExtDataImage = userExtData
      .map { $0.image }
    
    let sections = Driver<[SettingSection]>.just([
      SettingSection(header: "Изменить аватарку:", items: [
        SettingItem(text: "Выбрать фото", type: .photo),
        SettingItem(text: "Открыть камеру", type: .camera)
      ])
    ])

    let selection = input.selection
      .withLatestFrom(sections) { indexPath, sections -> SettingItem in
        sections[indexPath.section].items[indexPath.item]
      }
    
    let selectionHandler = selection
      .withLatestFrom(userExtData) { item, extUserData -> AppStep? in
        switch item.type {
        case .camera:
          return .extUserDataCameraForIsRequired(extUserData: extUserData)
        case .photo:
          return .extUserDataPhotoLibraryForIsRequired(extUserData: extUserData)
        default:
          return nil
        }
      }
      .compactMap { $0 }
      .do { step in
        self.steps.accept(step)
      }
    
    return Output(
      userExtDataImage: userExtDataImage,
      sections: sections,
      selectionHandler: selectionHandler
    )
  }
}
