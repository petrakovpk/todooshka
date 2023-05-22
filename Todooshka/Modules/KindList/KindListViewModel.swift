//
//  KindOfTaskListViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 24.06.2021.
//

import CoreData
import Foundation
import RxFlow
import RxSwift
import RxCocoa

enum KindListMode {
  case deleted
  case normal
}

class KindListViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  public let swipeDeleteButtonClickTrigger = PublishRelay<IndexPath>()
  public let kindListMode: KindListMode
  
  private let services: AppServices

  struct Input {
    // header buttons
    let addButtonClickTrigger: Driver<Void>
    let backButtonClickTrigger: Driver<Void>
    let removeAllButtonClickTrigger: Driver<Void>
    // kind list
    let kindSelected: Driver<IndexPath>
    let kindMoved: Driver<ItemMovedEvent>
    // alert
    let alertCancelButtonClickTrigger: Driver<Void>
    let alertDeleteButtonClickTrigger: Driver<Void>
  }

  struct Output {
    // header
    let navigateBack: Driver<AppStep>
    let addKind: Driver<AppStep>
    // kind list
    let kindListSections: Driver<[KindListSection]>
    let kindListOpenKind: Driver<AppStep>
    let kindListMoveItem: Driver<Void>
    // alert
    let alertIsHidden: Driver<Bool>
    // remove
    let kindRemove: Driver<Void>
    let kindRemoveAllDeleted: Driver<Void>
  }

  // MARK: - Init
  init(services: AppServices, kindListMode: KindListMode) {
    self.services = services
    self.kindListMode = kindListMode
  }

  func transform(input: Input) -> Output {
    let swipeDeleteButtonClickTrigger = swipeDeleteButtonClickTrigger.asDriverOnErrorJustComplete()

    let kinds = services.currentUserService.kinds
      .map { kinds -> [Kind] in
        switch self.kindListMode {
        case .deleted:
          return kinds.filter { $0.status == .deleted }
        case .normal:
          return kinds.filter { $0.status != .deleted }
        }
      }
    
    let kindListItems = kinds
      .map { kinds -> [KindListItem] in
        kinds.map { kind -> KindListItem in
          KindListItem(
            kind: kind,
            cellMode: self.kindListMode == .deleted ? .repeatButton : .empty
          )
        }
      }
    
    let kindListSections = kindListItems
      .map { kindListItems -> KindListSection in
        KindListSection(header: "", items: kindListItems)
      }
      .map {
        [$0]
      }
    
    let kindListOpenKind = input.kindSelected
      .withLatestFrom(kindListSections) { indexPath, sections -> KindListItem in
        sections[indexPath.section].items[indexPath.item]
      }
      .map { kindListItem -> AppStep in
        AppStep.openKindIsRequired(kind: kindListItem.kind)
      }
      .do { step in
        self.steps.accept(step)
      }
    
    let kindListMoveItem = input.kindMoved
      .withLatestFrom(kindListSections) { event, sections -> [Kind] in
        // Найти элемент для перемещения и удалить его из исходной секции
        let itemToMove = sections[event.sourceIndex.section].items[event.sourceIndex.item]
        var updatedItems = sections[event.sourceIndex.section].items
        updatedItems.remove(at: event.sourceIndex.item)
        
        // Вставить элемент в новое место
        updatedItems.insert(itemToMove, at: event.destinationIndex.item)

        return updatedItems.enumerated().map { index, item -> Kind in
          var kind = item.kind
          kind.index = index
          return kind
        }
  
      }
      .asObservable()
      .flatMapLatest { kinds -> Observable<Void> in
        StorageManager.shared.managedContext.rx.batchUpdate(kinds)
      }
      .asDriver(onErrorJustReturn: ())
   
    let swipeDeleteKind = swipeDeleteButtonClickTrigger
      .withLatestFrom(kindListSections) { indexPath, sections -> KindListItem in
        sections[indexPath.section].items[indexPath.item]
      }
    
    let showAlertTrigger = swipeDeleteKind.mapToVoid()
    let hideAlertTrigger = Driver.of(input.alertCancelButtonClickTrigger, input.alertDeleteButtonClickTrigger)
      .merge()
    
    let removeAlertIsHidden = Driver.of(
      showAlertTrigger.map { false },
      hideAlertTrigger.map { true }
    )
      .merge()
    
    let kindRemove = input.alertDeleteButtonClickTrigger
      .withLatestFrom(swipeDeleteKind)
      .map { item -> Kind in
        var kind = item.kind
        kind.status = .deleted
        return kind
      }
      .asObservable()
      .flatMapLatest { kind -> Observable<Void> in
        StorageManager.shared.managedContext.rx.update(kind)
      }
      .asDriver(onErrorJustReturn: ())
   
    let navigateBack = input.backButtonClickTrigger
      .map { AppStep.navigateBack }
      .do { step in
        self.steps.accept(step)
      }
    
    let addKind = input.addButtonClickTrigger
      .map { AppStep.openKindIsRequired(kind: Kind(uuid: UUID())) }
      .do { step in
        self.steps.accept(step)
      }
    
    
    let kindRemoveAllDeleted = input.removeAllButtonClickTrigger
      .withLatestFrom(kinds)
      .asObservable()
      .flatMapLatest { kinds -> Observable<Void> in
        StorageManager.shared.managedContext.rx.batchDelete(kinds)
      }
      .asDriver(onErrorJustReturn: ())

    return Output(
      // header
      navigateBack: navigateBack,
      addKind: addKind,
      // kind list
      kindListSections: kindListSections,
      kindListOpenKind: kindListOpenKind,
      kindListMoveItem: kindListMoveItem,
      // alert
      alertIsHidden: removeAlertIsHidden,
      // kind
      kindRemove: kindRemove,
      kindRemoveAllDeleted: kindRemoveAllDeleted
    )
  }
}
