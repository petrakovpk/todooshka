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
  
  private let services: AppServices
  
  let steps = PublishRelay<Step>()
  let color: Driver<UIColor>

  struct Output {
    let isSelected: Driver<Bool>
    let color: Driver<UIColor>
  }

  //MARK: - Init
  init(services: AppServices, taskTypeColorItem: TaskTypeColorItem) {
    self.services = services
    self.color = Driver<UIColor>.just(taskTypeColorItem.color)
  }
  
  func transform() -> Output {
    
    let isSelected = services.coreDataService.selectedTaskTypeColor
      .withLatestFrom(color) { color1, color2 -> Bool in
        return color1?.hexString == color2.hexString }
      .asDriver(onErrorJustReturn: false)
    
    return Output (
      isSelected: isSelected,
      color: color
    )
  }
  
}
