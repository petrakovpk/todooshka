//
//  TaskStepper.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 19.05.2021.
//

import RxFlow
import RxSwift
import RxCocoa

class TaskSteppers: Stepper {
    
    let steps = PublishRelay<Step>()
    private let appServices: AppServices
    private let disposalBag = DisposeBag()
 
    init(withServices services: AppServices) {
        self.appServices = services
    }
    
    var initialStep: Step {
      return AppStep.MainTaskListIsRequired
    }
    
}
