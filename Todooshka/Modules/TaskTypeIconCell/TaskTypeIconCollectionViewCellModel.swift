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
  
  private let services: AppServices
  
  let disposeBag = DisposeBag()
  let steps = PublishRelay<Step>()
  
  //MARK: - Из модели во Вью Контроллер
  let taskTypeIcon = BehaviorRelay<TaskTypeIconItem?>(value: nil)

  //MARK: - Init
  init(services: AppServices, taskTypeIcon: TaskTypeIconItem) {
    self.services = services
    self.taskTypeIcon.accept(taskTypeIcon)
  }
  
}

