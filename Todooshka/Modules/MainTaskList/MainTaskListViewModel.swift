//
//  MainTaskListViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 05.04.2022.
//

import RxFlow
import RxSwift
import RxCocoa
import UIKit

class MainTaskListViewModel: Stepper {
  
  //MARK: - Properties
  let steps = PublishRelay<Step>()
  let services: AppServices
  let disposeBag = DisposeBag()
  
  struct Input {
    // idea
    let ideaButtonClickTrigger: Driver<Void>
    // overdued
    let overduedButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    // idea
    let ideaButtonClick: Driver<Void>
    // overdued
    let overduedButtonClick: Driver<Void>
    // egg
  }
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  func transform(input: Input) -> Output {
    
    // idea
    let ideaButtonClick = input.ideaButtonClickTrigger
      .map { self.steps.accept(AppStep.IdeaTaskListIsRequired) }
    
    // overdued
    let overduedButtonClick = input.overduedButtonClickTrigger
      .map { self.steps.accept(AppStep.OverduedTaskListIsRequired) }
    
    return Output(
      // idea
      ideaButtonClick: ideaButtonClick,
      // overdued
      overduedButtonClick: overduedButtonClick
    )
  }
}

