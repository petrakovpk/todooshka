//
//  ChangeGenderViewModel.swift
//  Todooshka
//
//  Created by Pavel Petakov on 12.09.2022.
//

import RxFlow
import RxSwift
import RxCocoa

class ChangeGenderViewModel: Stepper {
  
  let services: AppServices
  let steps = PublishRelay<Step>()
  let gender = BehaviorRelay<Gender>(value: .Other)

  struct Input {
    let backButtonClickTrigger: Driver<Void>
    let selection: Driver<IndexPath>
  }
  
  struct Output {
    let dataSource: Driver<[ChangeGenderSectionModel]>
    let itemSelected: Driver<Void>
    let navigateBack: Driver<Void>
  }
  
  //MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  func transform(input: Input) -> Output {
    
    let gender = gender.asDriver()
    
    let navigateBack = input.backButtonClickTrigger
      .map { _ in self.steps.accept(AppStep.NavigateBack) }
    
    let dataSource = gender
      .map { gender -> [ChangeGenderSectionModel] in
        [ChangeGenderSectionModel(header: "Выберите пол", items: [
          ChangeGenderItem(text: "Мужчина", isSelected: gender == .Male , gender: .Male),
          ChangeGenderItem(text: "Женщина", isSelected: gender == .Female , gender: .Female),
          ChangeGenderItem(text: "Другой гендер", isSelected: gender == .Other, gender: .Other)
        ])]
      }
    
    let itemSelected = input.selection
      .withLatestFrom(dataSource) { $1[$0.section].items[$0.item].gender }
      .map { gender -> Void in
        self.gender.accept(gender)
      }
    
    return Output(
      dataSource: dataSource,
      itemSelected: itemSelected,
      navigateBack: navigateBack
    )
  }
  
}

