//
//  AppStepper.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import RxFlow
import RxSwift
import RxCocoa

class AppStepper: Stepper {
    
    let steps = PublishRelay<Step>()
    private let appServices: AppServices
    private let disposalBag = DisposeBag()
    
    init(withServices services: AppServices) {
        self.appServices = services
    }
    
    var initialStep: Step {
        
        //MARK: - Проверяем нужен ли онбоардинг
        return AppStep.onboardingIsCompleted
    }
}
