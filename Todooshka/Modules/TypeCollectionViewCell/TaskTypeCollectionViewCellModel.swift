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
  let steps = PublishRelay<Step>()

  private let services: AppServices
  private let disposeBag = DisposeBag()
  private let type: TaskType
  private let formatter = DateFormatter()

  struct Output {
    // text
    let text: Driver<String>
    // Image
    let image: Driver<UIImage>
    // Color
    let color: Driver<UIColor>
    // isSelected
    let isSelected: Driver<Bool>
  }

  // MARK: - Из модели во Вью Контроллер
  init(services: AppServices, type: TaskType) {
    self.services = services
    self.type = type
  }

  func transform() -> Output {
    // text
    let text = Driver<String>.just(type.text)

    // image
    let image = Driver<UIImage>.just(type.icon.image)

    // isSelected
    let isSelected = Driver<Bool>.just(type.isSelected)

//    services.typesService.selectedType
//      .map { $0.UID == self.type.UID }
//      .asDriver(onErrorJustReturn: false)

    // color
    let color = Driver<UIColor>
      .just(type.color.uiColor)
      .withLatestFrom(isSelected) { uiColor, isSelected -> UIColor in
        isSelected ? .white : uiColor
      }

    return Output(
      text: text,
      image: image,
      color: color,
      isSelected: isSelected
    )
  }
}
