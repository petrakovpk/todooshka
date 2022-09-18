//
//  TaskTypeListCollectionViewCellModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 08.09.2021.
//
//
//import RxFlow
//import RxSwift
//import RxCocoa
//import Foundation
//import SwipeCellKit
//import UIKit
//
//class TaskTypeListCollectionViewCellModel: Stepper {
//
//  let steps = PublishRelay<Step>()
//
//  private let services: AppServices
//  private let formatter = DateFormatter()
//  private var kindOfTask: KindOfTask
//
//  struct Input {
//    let repeatButtonClickTrigger: Driver<Void>
//  }
//
//  struct Output {
//    // buttons
//    let repeatButtonIsHidden: Driver<Bool>
//    let repeatButtonClicked: Driver<Void>
//
//    // image
//    let image: Driver<UIImage>
//
//    // color
//    let color: Driver<UIColor>
//
//    // text
//    let text: Driver<String>
//  }
//
//
//  //MARK: - Init
//  init(services: AppServices, kindOfTask: KindOfTask) {
//    self.services = services
//    self.kindOfTask = kindOfTask
//  }
//
//  func transform(input: Input) -> Output {
//
//    // image
//    let image = Driver<UIImage>.just(kindOfTask.icon.image)
//
//    // color
//    let color = Driver<UIColor>.just(kindOfTask.color)
//
//    //text
//    let text = Driver<String>.just(kindOfTask.text)
//
//    let repeatButtonClick = input.repeatButtonClickTrigger
////      .do { _ in
////        self.type.status = .active
////        self.services.typesService.saveTypesToCoreData(types: [self.type])
////      }
//
//    let repeatButtonIsHidden = Driver.just(kindOfTask.status == .active)
//
//    return Output(
//      // buttons
//      repeatButtonIsHidden: repeatButtonIsHidden,
//      repeatButtonClicked: repeatButtonClick,
//      // image
//      image: image,
//      // color
//      color: color,
//      // text
//      text: text
//    )
//  }
//
//}
//

//
//
