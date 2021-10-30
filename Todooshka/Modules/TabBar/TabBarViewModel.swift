//
//  TabBarViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 28.07.2021.
//


import RxFlow
import RxSwift
import RxCocoa
import Firebase

class TabBarViewModel: Stepper {
  
  let steps = PublishRelay<Step>()
  let disposeBag = DisposeBag()
  let services: AppServices
  
  struct Input {
    let createTaskButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    let createTask: Driver<Void>
  }
  
  init(services: AppServices) {
    self.services = services
  }
  
  func transform(input: Input) -> Output {
    
    let createTask = input.createTaskButtonClickTrigger
      .map { self.steps.accept(AppStep.createTaskIsRequired(status: .created, createdDate: nil)) }
    
    return Output(createTask: createTask)
  }
  

}
