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
  private let color: UIColor

  struct Output {
    let color: Driver<UIColor>
    let isSelected: Driver<Bool>
  }

  // MARK: - Init
  init(services: AppServices, color: UIColor) {
    self.services = services
    self.color = color
  }

  func transform() -> Output {

    // color
    let color = Driver<UIColor>.just(self.color)

    // isSelected
    let isSelected = Driver.just(true)
//    let isSelected = services.typesService.selectedTypeColor
//      .map { $0 == self.color }
//      .asDriver(onErrorJustReturn: false)

    return Output(
      color: color,
      isSelected: isSelected
    )
  }

}
