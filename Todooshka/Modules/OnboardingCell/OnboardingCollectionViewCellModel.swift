//
//  OnboardingCollectionViewCellModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.08.2021.
//

import UIKit
import RxFlow
import RxSwift
import RxCocoa
import Foundation
import SwipeCellKit

class OnboardingCollectionViewCellModel: Stepper {

  // MARK: - Properties
  let disposeBag = DisposeBag()
  let steps = PublishRelay<Step>()

  private let services: AppServices
  private let onboardingSectionItem: OnboardingSectionItem

  struct Output {
    let headerText: Driver<String>
    let descriptionText: Driver<String>
    let image: Driver<UIImage>
  }

  // MARK: - Init
  init(services: AppServices, onboardingSectionItem: OnboardingSectionItem) {
    self.services = services
    self.onboardingSectionItem = onboardingSectionItem
  }

  func transform() -> Output {

    let headerText = Driver<String>.just(onboardingSectionItem.header)
    let descriptionText = Driver<String>.just(onboardingSectionItem.description)
    let image = Driver<UIImage>.just(onboardingSectionItem.image)

    return Output(
      headerText: headerText,
      descriptionText: descriptionText,
      image: image
    )
  }
}
