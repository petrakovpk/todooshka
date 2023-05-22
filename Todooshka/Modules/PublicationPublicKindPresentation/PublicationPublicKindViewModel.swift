//
//  PublicationPublicKindViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 19.05.2023.
//

import RxCocoa
import RxFlow
import RxSwift
import UIKit

class PublicationPublicKindViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  
  private let disposeBag = DisposeBag()
  private let services: AppServices
  private let publication: Publication
  
  struct Input {
    let selection: Driver<IndexPath>
  }
  
  struct Output {
    let publicKindSections: Driver<[PublicKindSection]>
    let publicationUpdatePublicKind: Driver<Publication>
  }
  
  // MARK: - Init
  init(services: AppServices, publication: Publication) {
    self.services = services
    self.publication = publication
  }
  
  func transform(input: Input) -> Output {
    let errorTracker = ErrorTracker()
    
    let publicKinds = services.currentUserService.publicKinds.debug()
    
    let publication = services.temporaryDataService.temporaryPublication
      .asDriver()
      .compactMap { $0 }
      .startWith(self.publication)
      
    let publicKindEmptyItem = publication
      .map { publication -> PublicKindItem in
        PublicKindItem(
          publicKindItemType: .empty,
          isSelected: publication.publicKindUUID == nil
        )
      }
    
    let publicKindItems = Driver
      .combineLatest(publicKinds, publication) { publicKinds, publication -> [PublicKindItem] in
        publicKinds.map { publicKind -> PublicKindItem in
          PublicKindItem(
            publicKindItemType: .kind(kind: publicKind),
            isSelected: publication.publicKindUUID == publicKind.uuid
          )
        }
      }
    
    let publicKindSections = Driver
      .combineLatest(publicKindEmptyItem, publicKindItems) { publicKindEmptyItem, publicKindItems -> [PublicKindItem] in
        [publicKindEmptyItem] + publicKindItems
      }
      .map { items -> [PublicKindSection] in
        [PublicKindSection(header: "", items: items)]
      }
    
    let publicationUpdatePublicKind = input.selection
      .withLatestFrom(publicKindSections) { indexPath, questCategorySections -> PublicKindItem in
        questCategorySections[indexPath.section].items[indexPath.item]
      }
      .withLatestFrom(publication) { item, publication -> Publication in
        var publication = publication
        switch item.publicKindItemType {
        case .empty:
          publication.publicKindUUID = nil
        case .kind(kind: let kind):
          publication.publicKindUUID = kind.uuid
        }
        return publication
      }
      .do { publication in
        self.services.temporaryDataService.temporaryPublication.accept(publication)
      }

    return Output(
      publicKindSections: publicKindSections,
      publicationUpdatePublicKind: publicationUpdatePublicKind
    )
  }
}


