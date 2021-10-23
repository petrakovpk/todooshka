//
//  TaskTypeCollectionViewCellModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 04.08.2021.
//


import RxFlow
import RxSwift
import RxCocoa
import Foundation
import SwipeCellKit


class TaskTypeCollectionViewCellModel: Stepper {
  
  private let services: AppServices
  
  let disposeBag = DisposeBag()
  let steps = PublishRelay<Step>()
  
  let formatter = DateFormatter()
  let type: TaskType
  let isSelected = BehaviorRelay<Bool?>(value: nil)
  
  
  
  struct Output {
    let typeImageColor: Driver<UIColor>
    let typeImage: Driver<UIImage>
    let typeText: Driver<String>
    let isSelected: Driver<Bool>
  }
  
  //MARK: - Из модели во Вью Контроллер
  init(services: AppServices, type: TaskType) {
    self.services = services
    self.type = type
  }
  
  func transform() -> Output {
    
    let typeImageColor = Driver<UIColor>.just(type.imageColor!)
    let typeImage = Driver<UIImage>.just(type.image!)
    let typeText = Driver<String>.just(type.text)
    
    let isSelected = services.coreDataService.selectedTaskType
      .map { return self.type == $0 }
      .asDriver(onErrorJustReturn: false)
    
    return Output(
      typeImageColor: typeImageColor,
      typeImage: typeImage,
      typeText: typeText,
      isSelected: isSelected)
  }
  
}

