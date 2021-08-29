//
//  OnboardingViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.08.2021.
//

import RxFlow
import RxSwift
import RxCocoa
import Firebase

class OnboardingViewModel: Stepper {
    
    //MARK: - Properties
    let steps = PublishRelay<Step>()
    let disposeBag = DisposeBag()
    let services: AppServices
    
    let dataSource = BehaviorRelay<[OnboardingSectionModel]>(value: [])
    
    //MARK: - Output
    let authButtonIsHidden = BehaviorRelay<Bool>(value: true)
    
    //MARK: - Init
    init(services: AppServices) {
        self.services = services
        
        var models: [OnboardingSectionModel] = []
        
        let onboardingSectionItem1 = OnboardingSectionItem(header: "Onboarding header", description: "Brief description of onboarding that can be placed in two lines", image: UIImage(named: "Onboarding1")!)
        let onboardingSectionItem2 = OnboardingSectionItem(header: "Onboarding header", description: "Brief description of onboarding that can be placed in two lines", image: UIImage(named: "Onboarding2")!)
        let onboardingSectionItem3 = OnboardingSectionItem(header: "Onboarding header", description: "Brief description of onboarding that can be placed in two lines", image: UIImage(named: "Onboarding3")!)
        
        models.append(OnboardingSectionModel(items: [onboardingSectionItem1]))
        models.append(OnboardingSectionModel(items: [onboardingSectionItem2]))
        models.append(OnboardingSectionModel(items: [onboardingSectionItem3]))
        
        dataSource.accept(models)
        
        services.networkAuthService.currentUser.bind{ [weak self] user in
            guard let self = self else { return }
            if user == nil {
                self.authButtonIsHidden.accept(false)
            } else {
                self.authButtonIsHidden.accept(true)
            }
        }.disposed(by: disposeBag)
        
    }
    
    func skipButtonClick() {
        UserDefaults.standard.setValue(true, forKey: "isOnboardingCompleted")
        steps.accept(AppStep.onboardingIsCompleted)
    }
    
    func authButtonClick() {
        steps.accept(AppStep.authIsRequired)
    }
    
}

