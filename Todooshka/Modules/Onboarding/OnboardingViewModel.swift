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
        
        let onboardingSectionItem1 = OnboardingSectionItem(header: "Добро пожаловать в Тудушку!", description: "Хочешь разложить все дела по полочкам, не откладывая на завтра? Мы поможем это сделать сегодня, тебе понравится!", image: UIImage(named: "Onboarding1")!)
        let onboardingSectionItem2 = OnboardingSectionItem(header: "Календарь", description: "Будь в курсе дел на каждый день, не забывай проверять календарь", image: UIImage(named: "Onboarding2")!)
        let onboardingSectionItem3 = OnboardingSectionItem(header: "Герой", description: "Награда не заставит себя долго ждать, если ты выполнил поставленные задачи вовремя. Сам себя не похвалишь, зато это сделает Тудушка!", image: UIImage(named: "Onboarding3")!)
        
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

