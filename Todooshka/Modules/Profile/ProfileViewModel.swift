//
//  ProfileViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 11.01.2023.
//

import Firebase
import RxFlow
import RxSwift
import RxCocoa

class ProfileViewModel: Stepper {
  let services: AppServices
  let steps = PublishRelay<Step>()
  
  struct Input {
    
  }
  
  struct Output {
    let dataSource: Driver<[TaskListSection]>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {

    let dataSource = Driver<[TaskListSection]>.just([])
    
    return Output(
      dataSource: dataSource
    )
  }
}
