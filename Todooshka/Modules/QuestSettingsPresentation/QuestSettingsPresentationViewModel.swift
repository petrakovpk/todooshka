//
//  QuestPresentationViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 12.05.2023.
//

import RxCocoa
import RxFlow
import RxSwift

class QuestSettingsPresentationViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  
  private let services: AppServices
  private let quest: Quest
  private let disposeBag = DisposeBag()
  
  struct Input {
    let selection: Driver<IndexPath>
  }
  
  struct Output {
    let settingSections: Driver<[SettingSection]>
    let returnToDraft: Driver<AppStep>
    let remove: Driver<AppStep>
  }
  
  // MARK: - Init
  init(services: AppServices, quest: Quest) {
    self.services = services
    self.quest = quest
  }
  
  func transform(input: Input) -> Output {

    let settingSections = Driver<[SettingSection]>.of([
      SettingSection(header: "", items: [
        SettingItem(text: "Отменить публикацию", type: .draftIsRequired),
        SettingItem(text: "Удалить", type: .deleteIsRequired)
      ])
    ])
    
    let returnToDraft = input.selection
      .withLatestFrom(settingSections) { indexPath, settingSections -> SettingItem in
        settingSections[indexPath.section].items[indexPath.item]
      }
      .filter { $0.type == .draftIsRequired }
      .map { _ -> Quest in
        var quest = self.quest
        quest.status = .draft
        return quest
      }
      .flatMapLatest { quest -> Driver<Void> in
        StorageManager.shared.managedContext.rx
          .update(quest)
          .asDriverOnErrorJustComplete()
      }
      .map { _ -> AppStep in
          .dismiss
      }
      .do { step in
        self.steps.accept(step)
      }
    
    let remove = input.selection
      .withLatestFrom(settingSections) { indexPath, settingSections -> SettingItem in
        settingSections[indexPath.section].items[indexPath.item]
      }
      .filter { $0.type == .deleteIsRequired }
      .flatMapLatest { _ -> Driver<Void> in
        StorageManager.shared.managedContext.rx
          .delete(self.quest)
          .asDriverOnErrorJustComplete()
      }
      .map { _ -> AppStep in
          .dismissAndNavigateBack
      }
      .do { step in
        self.steps.accept(step)
      }
    
    return Output(
      settingSections: settingSections,
      returnToDraft: returnToDraft,
      remove: remove
    )
  }
}
