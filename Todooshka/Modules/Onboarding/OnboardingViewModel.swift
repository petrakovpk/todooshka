//
//  OnboardingViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.08.2021.
//

import RxFlow
import RxSwift
import RxCocoa
import UIKit

class OnboardingViewModel: Stepper {
  
  //MARK: - Properties
  let steps = PublishRelay<Step>()
  let disposeBag = DisposeBag()
  let services: AppServices
  
  struct Input {
    let skipButtonClickTrigger: Driver<Void>
    let cellScrolled: Driver<Int>
  }
  
  struct Output {
    let dataSource: Driver<[OnboardingSectionModel]>
    let skipButtonClick: Driver<Int?>
    let skipButtonTitle: Driver<String>
    let cellScrolled: Driver<Int>
    let backgroundImage: Driver<UIImage?>
  }
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  func transform(input: Input) -> Output {
    
    let onboardingSectionItem1 = OnboardingSectionItem(header: "Добро пожаловать в Тудушку!", description: "Хочешь разложить все дела по полочкам, не откладывая на завтра? \n Мы поможем это сделать сегодня, тебе понравится!", image: UIImage(named: "Onboarding1")!)
    let onboardingSectionItem2 = OnboardingSectionItem(header: "Календарь", description: "Будь в курсе дел на каждый день, не забывай проверять календарь", image: UIImage(named: "Onboarding2")!)
    let onboardingSectionItem3 = OnboardingSectionItem(header: "Герой", description: "Награда не заставит себя долго ждать, если ты выполнил поставленные задачи вовремя. Сам себя не похвалишь, зато это сделает Тудушка!", image: UIImage(named: "Onboarding3")!)
    
    let dataSource = Driver<[OnboardingSectionModel]>.just([
      OnboardingSectionModel(items: [onboardingSectionItem1]),
      OnboardingSectionModel(items: [onboardingSectionItem2]),
      OnboardingSectionModel(items: [onboardingSectionItem3])
    ])
    
    let skipButtonClick = input.skipButtonClickTrigger
      .withLatestFrom(input.cellScrolled) { _, cellIndex -> Int? in
        if cellIndex == 0 { return 1 }
        if cellIndex == 1 { return 2 }
        if cellIndex == 2 {
          UserDefaults.standard.setValue(true, forKey: "isOnboardingCompleted")
          self.steps.accept(AppStep.OnboardingIsCompleted)
        }
        return nil
      }
    
    let skipButtonTitle = input.cellScrolled
      .map { cellIndex -> String in
        if cellIndex == 0 { return "Далее"}
        if cellIndex == 1 { return "Далее"}
        if cellIndex == 2 { return "НАЧНЕМ!"}
        return ""
      }
      .distinctUntilChanged()
    
    let cellScrolled = input.cellScrolled
    
    let backgroundImage = input.cellScrolled
      .map { cellIndex -> UIImage? in
        let imageName  = "Onboarding" + String(cellIndex + 1) + "Background"
        guard let image = UIImage(named: imageName) else { return nil }
        return image
      }
    
    return Output(
      dataSource: dataSource,
      skipButtonClick: skipButtonClick,
      skipButtonTitle: skipButtonTitle,
      cellScrolled: cellScrolled,
      backgroundImage: backgroundImage
    )
  }
}

