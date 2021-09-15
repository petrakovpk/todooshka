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
  
  let disposeBag = DisposeBag()
  let steps = PublishRelay<Step>()
  
  //MARK: - Из модели во Вью Контроллер
  let taskTypeColorItem = BehaviorRelay<TaskTypeColorItem?>(value: nil)
  let isSelected = BehaviorRelay<Bool>(value: false)

  //MARK: - Init
  init(services: AppServices, taskTypeColorItem: TaskTypeColorItem) {
    self.services = services
    self.taskTypeColorItem.accept(taskTypeColorItem)
    
    services.coreDataService.selectedTaskTypeColor.bind{ [weak self] color in
      guard let self = self else { return }
      self.isSelected.accept( color == taskTypeColorItem.color )
    }.disposed(by: disposeBag)
  }
}
