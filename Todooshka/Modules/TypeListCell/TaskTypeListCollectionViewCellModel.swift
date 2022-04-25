//
//  TaskTypeListCollectionViewCellModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 08.09.2021.
//

import RxFlow
import RxSwift
import RxCocoa
import Foundation
import SwipeCellKit
import UIKit

class TaskTypeListCollectionViewCellModel: Stepper {
  
  let steps = PublishRelay<Step>()
  
  private let services: AppServices
  private let formatter = DateFormatter()
  private var type: TaskType
  
  struct Input {
    let repeatButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    // buttons
    let repeatButtonIsHidden: Driver<Bool>
    let repeatButtonClicked: Driver<Void>
    
    // image
    let image: Driver<UIImage>
    
    // color
    let color: Driver<UIColor>
    
    // text
    let text: Driver<String>
  }
  
  
  //MARK: - Init
  init(services: AppServices, type: TaskType) {
    self.services = services
    self.type = type
  }
  
  func transform(input: Input) -> Output {
    
    // image
    let image = Driver<UIImage>.just(type.icon.image)
    
    // color
    let color = Driver<UIColor>.just(type.color.uiColor)
    
    //text
    let text = Driver<String>.just(type.text)
    
    let repeatButtonClick = input.repeatButtonClickTrigger
      .do { _ in
        self.type.status = .active
        self.services.typesService.saveTypesToCoreData(types: [self.type])
      }
    
    let repeatButtonIsHidden = Driver.just(type.status == .active)
    
    return Output(
      // buttons
      repeatButtonIsHidden: repeatButtonIsHidden,
      repeatButtonClicked: repeatButtonClick,
      // image
      image: image,
      // color
      color: color,
      // text
      text: text
    )
  }
  
}

//MARK: - SwipeCollectionViewCellDelegate
extension TaskTypeListCollectionViewCellModel: SwipeCollectionViewCellDelegate {
  
  func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
    
    guard orientation == .right else { return nil }
    
    let deleteAction = SwipeAction(style: .destructive, title: nil) { [weak self] action, indexPath in
      guard let self = self else { return }
      action.fulfill(with: .reset)
      self.services.typesService.typeRemovingIsRequired.accept(self.type)
    }
    
    configure(action: deleteAction, with: .trash)
    deleteAction.backgroundColor = Theme.App.background
    return [deleteAction]
  }
  
  func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
    var options = SwipeOptions()
    options.expansionStyle = .destructive
    options.transitionStyle = .border
    return options
  }
  
  func configure(action: SwipeAction, with descriptor: ActionDescriptor) {
    let buttonDisplayMode: ButtonDisplayMode = .imageOnly
    let buttonStyle: ButtonStyle = .circular
    
    action.title = descriptor.title(forDisplayMode: buttonDisplayMode)
    action.image = descriptor.image(forStyle: buttonStyle, displayMode: buttonDisplayMode, size: CGSize(width: 30, height: 30))
    
    switch buttonStyle {
    case .backgroundColor:
      action.backgroundColor = descriptor.color(forStyle: buttonStyle)
    case .circular:
      action.backgroundColor = .clear
      action.textColor = descriptor.color(forStyle: buttonStyle)
      action.font = .systemFont(ofSize: 9)
      action.transitionDelegate = ScaleTransition.default
    }
  }
}


