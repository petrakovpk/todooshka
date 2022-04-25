//
//  TaskTypeColorCollectionViewCellModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 15.09.2021.
//

import RxFlow
import RxSwift
import RxCocoa
import Foundation
import SwipeCellKit

class TaskTypeColorCollectionViewCellModel: Stepper {
  
  let steps = PublishRelay<Step>()
  
  private let services: AppServices
  private let color: TypeColor
  
  struct Output {
    let color: Driver<UIColor>
    let isSelected: Driver<Bool>
  }

  //MARK: - Init
  init(services: AppServices, color: TypeColor) {
    self.services = services
    self.color = color
  }
  
  func transform() -> Output {
    
    // color
    let color = Driver<UIColor>.just(self.color.uiColor)
    
    // isSelected
    let isSelected = services.typesService.selectedTypeColor
      .map { $0 == self.color }
      .asDriver(onErrorJustReturn: false)
    
    return Output (
      color: color,
      isSelected: isSelected
    )
  }
  
}
