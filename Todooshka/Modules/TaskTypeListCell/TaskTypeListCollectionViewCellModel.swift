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
  
  private let services: AppServices
  
 // let disposeBag = DisposeBag()
  let steps = PublishRelay<Step>()
  
  let formatter = DateFormatter()
  let type: TaskType
  
  
  struct Input {
    let repeatButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    let icon: Driver<UIImage>
    let color: Driver<UIColor>
    let text: Driver<String>
    let repeatButtonClicked: Driver<Void>
    let repeatButtonIsHidden: Driver<Bool>
  }
  

  //MARK: - Init
  init(services: AppServices, type: TaskType) {
    self.services = services
    self.type = type
  }
  
  func transform(input: Input) -> Output {
    
    let icon = Driver<UIImage>.just(type.image!)
    let color = Driver<UIColor>.just(type.imageColor!)
    let text = Driver<String>.just(type.text)
    
    let repeatButtonClick = input.repeatButtonClickTrigger.map {
      self.type.status = .active
      self.services.coreDataService.saveTaskTypesToCoreData(types: [self.type]) { error in
        if let error = error  {
          print(error.localizedDescription)
          return
        }
      }
    }
    
    let repeatButtonIsHidden = Driver.just(type.status == .active)
    
    
    return Output(
      icon: icon,
      color: color,
      text: text,
      repeatButtonClicked: repeatButtonClick,
      repeatButtonIsHidden: repeatButtonIsHidden
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
      self.services.coreDataService.taskTypeRemovingIsRequired.accept(self.type)
    }
    
    configure(action: deleteAction, with: .trash)
    deleteAction.backgroundColor = UIColor(named: "appBackground")
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


