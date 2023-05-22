//
//  UserProfilePublicationsViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 01.05.2023.
//

import RxFlow
import RxSwift
import RxCocoa

class UserProfilePublicationsViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  
  private let services: AppServices
  
  struct Input {
    let selection: Driver<IndexPath>
  }
  
  struct Output {
    let dataSource: Driver<[UserProfilePublicationSection]>
    let openPublication: Driver<AppStep>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {
    let publications = services.currentUserService.publications
    let publicationImages = services.currentUserService.publicationImages

    let publicationItems = Driver
      .combineLatest(publications, publicationImages) { publications, publicationImages -> [UserProfilePublicationItem] in
        publications.map { publication -> UserProfilePublicationItem in
          UserProfilePublicationItem(
            publication: publication,
            publicationImage: publicationImages.first { $0.publicationUUID == publication.uuid },
            viewsCount: 5)
        }
      }
    
    let publicationSections = publicationItems
      .map { items -> [UserProfilePublicationSection] in
        [
          UserProfilePublicationSection(header: "", items: items)
        ]
      }
    
    let openPublication = input.selection
      .debug()
      .withLatestFrom(publicationSections) { indexPath, sections -> Publication in
        sections[indexPath.section].items[indexPath.item].publication
      }
      .debug()
      .map { publication -> AppStep in
        AppStep.publicationIsRequired(publication: publication)
      }
      .debug()
      .do { step in
        self.steps.accept(step)
      }
     
    return Output(
      dataSource: publicationSections,
      openPublication: openPublication
    )
  }
}
