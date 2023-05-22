//
//  PublicationSettingsViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 09.05.2023.
//

import RxCocoa
import RxFlow
import RxSwift

class PublicationSettingsViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  
  private let disposeBag = DisposeBag()
    
  private let services: AppServices
  private let publication: Publication
  private let publicationImage: PublicationImage?
  
  struct Input {
    let selection: Driver<IndexPath>
  }
  
  struct Output {
    let settingSections: Driver<[SettingSection]>
    let edit: Driver<AppStep>
    let unpublish: Driver<AppStep>
    let remove: Driver<AppStep>
  }
  
  // MARK: - Init
  init(services: AppServices, publication: Publication, publicationImage: PublicationImage?) {
    self.services = services
    self.publication = publication
    self.publicationImage = publicationImage
  }
  
  func transform(input: Input) -> Output {

    let settingSections = Driver<[SettingSection]>.of([
      SettingSection(header: "", items: [
        SettingItem(text: "Редактировать", type: .edit),
        SettingItem(text: "Отменить публикацию", type: .draftIsRequired),
        SettingItem(text: "Удалить", type: .deleteIsRequired)
      ])
    ])
    
    let editPublication = input.selection
      .withLatestFrom(settingSections) { indexPath, settingSections -> SettingItem in
        settingSections[indexPath.section].items[indexPath.item]
      }
      .filter { $0.type == .edit }
      .map { _ -> AppStep in
          .publicationEditIsRequired(
            publication: self.publication,
            publicationImage: self.publicationImage)
      }
      .do { step in
        self.steps.accept(step)
      }
        
    let draftPublication = input.selection
      .withLatestFrom(settingSections) { indexPath, settingSections -> SettingItem in
        settingSections[indexPath.section].items[indexPath.item]
      }
      .filter { $0.type == .draftIsRequired }
      .map { _ -> Publication in
        var publication = self.publication
        publication.status = .unpublished
        return publication
      }
      .flatMapLatest { publication -> Driver<Void> in
        StorageManager.shared.managedContext.rx
          .update(publication)
          .asDriverOnErrorJustComplete()
      }
      .map { _ -> AppStep in
          .dismiss
      }
      .do { step in
        self.steps.accept(step)
      }
    
    let removePublication = input.selection
      .withLatestFrom(settingSections) { indexPath, settingSections -> SettingItem in
        settingSections[indexPath.section].items[indexPath.item]
      }
      .filter { $0.type == .deleteIsRequired }
      .flatMapLatest { _ -> Driver<Void> in
        StorageManager.shared.managedContext.rx
          .delete(self.publication)
          .asDriverOnErrorJustComplete()
      }
      .flatMapLatest { _ -> Driver<Void> in
        if let publicationImage = self.publicationImage {
          return StorageManager.shared.managedContext.rx
            .delete(publicationImage)
            .asDriverOnErrorJustComplete()
        } else {
          return Driver<Void>.just(())
        }
      }
      .map { _ -> AppStep in
          .dismissAndNavigateBack
      }
      .do { step in
        self.steps.accept(step)
      }
    
    return Output(
      settingSections: settingSections,
      edit: editPublication,
      unpublish: draftPublication,
      remove: removePublication
    )
  }
}
