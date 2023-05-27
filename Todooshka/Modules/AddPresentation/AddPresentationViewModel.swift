//
//  AddSheetViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 28.04.2023.
//

import RxCocoa
import RxFlow
import RxSwift

class AddPresentationViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  
  private let services: AppServices
  private let disposeBag = DisposeBag()
  
  struct Input {
    let createPublicationButtonClickTrigger: Driver<Void>
    let createTaskButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    let createPublication: Driver<AppStep>
    let createTask: Driver<AppStep>
  }
  
  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  func transform(input: Input) -> Output {
    let currentUser = services.currentUserService.user
    //let emptyKind = services.currentUserService.emptyKind
    
    let createPublication = input.createPublicationButtonClickTrigger
      .map { _ -> AppStep in
          .publicationIsRequired(publication: Publication(uuid: UUID()))
      }
      .do { step in
        self.steps.accept(step)
      }
    
    let createTask = input.createTaskButtonClickTrigger
      .map { _ -> AppStep in
          .openTaskIsRequired(
            task: Task(uuid: UUID(), status: .draft),
            taskListMode: .tabBar)
      }
      .do { step in
        self.steps.accept(step)
      }
    
    return Output(
      createPublication: createPublication,
      createTask: createTask
    )
  }
}
