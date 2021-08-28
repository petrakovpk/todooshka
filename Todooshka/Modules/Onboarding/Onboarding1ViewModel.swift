//
//  OnboardingViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 11.07.2021.
//


import RxFlow
import RxSwift
import RxCocoa
import Firebase
import CoreData

class OnboardingViewModel: Stepper {
    
    let steps = PublishRelay<Step>()
    let disposeBag = DisposeBag()
    let services: AppServices
   
    init(services: AppServices) {
        self.services = services
        
    }
    
    func getStartedButtonClicked() {
        setOnboardedCompleted()
        steps.accept(AppStep.onboardingIsCompleted)
    }
    
    func setOnboardedCompleted() {
        UserDefaults.standard.set(true, forKey: "isOnboardingCompleted")
    }
}


