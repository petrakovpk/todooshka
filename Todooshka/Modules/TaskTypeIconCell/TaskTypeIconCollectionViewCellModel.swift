//
//  TaskTypeIconCollectionViewCellModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 07.09.2021.
//

import RxFlow
import RxSwift
import RxCocoa
import Foundation
import SwipeCellKit

class TaskTypeIconCollectionViewCellModel: Stepper {
  
  let steps = PublishRelay<Step>()
  
  private let services: AppServices
  private let taskTypeIcon: TaskTypeIconItem

  struct Output {
    let isSelected: Driver<Bool>
    let icon: Driver<UIImage?>
  }

  //MARK: - Init
  init(services: AppServices, taskTypeIcon: TaskTypeIconItem) {
    self.services = services
    self.taskTypeIcon = taskTypeIcon
  }
  
  func transform() -> Output {
    
    let isSelected = services.coreDataService.selectedTaskTypeIconName
      .map { return self.taskTypeIcon.imageName == $0 }
      .asDriver(onErrorJustReturn: false)
    
    let icon = Driver.just(self.taskTypeIcon.image)
    
    return Output(
      isSelected: isSelected,
      icon: icon
    )
  }
}
