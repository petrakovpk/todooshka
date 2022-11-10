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
  private let icon: Icon

  struct Output {
    let image: Driver<UIImage>
    let isSelected: Driver<Bool>
  }

  // MARK: - Init
  init(services: AppServices, icon: Icon) {
    self.services = services
    self.icon = icon
  }

  func transform() -> Output {
    // image
    let image = Driver.just(self.icon.image)

    // isSelected
    let isSelected = Driver.of(true)
//    let isSelected = services.typesService.selectedTypeIcon
//      .map { $0 == self.icon }
//      .asDriver(onErrorJustReturn: false)
//
    return Output(
      image: image,
      isSelected: isSelected
    )
  }
}
