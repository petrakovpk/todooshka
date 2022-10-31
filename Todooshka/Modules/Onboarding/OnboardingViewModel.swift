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
    let didScroll: Driver<Void>
    let skipButtonClickTrigger: Driver<Void>
    let willDisplayCell: Driver<Reactive<UICollectionView>.DisplayCollectionViewCellEvent>
  }
  
  struct Output {
    let backgroundImage: Driver<UIImage>
    let completeOnboarding: Driver<Void>
    let dataSource: Driver<[OnboardingSectionModel]>
    let reloadPoints: Driver<Void>
    let scrollToSection: Driver<Int>
    let skipButtonTitle: Driver<String>
  }
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  func transform(input: Input) -> Output {
    
    let onboardingSectionItem1 = OnboardingSectionItem(header: "Добро пожаловать в ДрагоДу!", description: "Хочешь разложить все дела по полочкам, не откладывая на завтра? \n Мы поможем это сделать сегодня, тебе понравится!", image: UIImage(named: "Onboarding1")!)
    let onboardingSectionItem2 = OnboardingSectionItem(header: "Фабрика птиц", description: "Открывай новых птичек для каждого вида задач, пора пополнить свое гнездышко! Используй перышки и бриллианты, не заставляй Драго ждать.", image: UIImage(named: "Onboarding2")!)
    let onboardingSectionItem3 = OnboardingSectionItem(header: "Календарь", description: "Будь в курсе дел на каждый день, не забывай проверять календарь", image: UIImage(named: "Onboarding3")!)
    
    
    let dataSource = Driver<[OnboardingSectionModel]>.just([
      OnboardingSectionModel(items: [onboardingSectionItem1]),
      OnboardingSectionModel(items: [onboardingSectionItem2]),
      OnboardingSectionModel(items: [onboardingSectionItem3])
    ])
    
    let reloadPoints = input.didScroll
    
    let skipButtonTitle = input.willDisplayCell
      .map { event -> String in
        event.at.section == 2 ? "Начнем!" : "Далее"
      }.startWith("Далее")
      .distinctUntilChanged()
    
    let scrollToSection = input.skipButtonClickTrigger
      .withLatestFrom(input.willDisplayCell) { $1 }
      .filter { $0.at.section <= 1 }
      .map { event -> Int in
        event.at.section + 1
      }.asDriver()
    
    let completeOnboarding = input.skipButtonClickTrigger
      .withLatestFrom(input.willDisplayCell) { $1 }
      .filter { $0.at.section == 2 }
      .map { _ in UserDefaults.standard.setValue(true, forKey: "isOnboardingCompleted") }
      .map { _ in self.steps.accept(AppStep.OnboardingIsCompleted) }
     
    let backgroundImage = input.willDisplayCell
      .compactMap { event -> UIImage? in
        UIImage(named: "Onboarding" + String(event.at.section + 1) + "Background")
      }
    
    return Output(
      backgroundImage: backgroundImage,
      completeOnboarding: completeOnboarding,
      dataSource: dataSource,
      reloadPoints: reloadPoints,
      scrollToSection: scrollToSection,
      skipButtonTitle: skipButtonTitle
    )
  }
}

