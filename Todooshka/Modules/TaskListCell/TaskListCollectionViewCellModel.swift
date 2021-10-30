//
//  TaskListCellViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 20.05.2021.
//

import RxFlow
import RxSwift
import RxCocoa
import Foundation
import SwipeCellKit

class TaskListCollectionViewCellModel: Stepper {
  
  let services: AppServices
  
  let steps = PublishRelay<Step>()
  let task: Task
  
  let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH'h' mm'm' ss's'"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
  }()
  
  var isEnabled: Bool = true
  
  struct Input {
    let repeatButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    let text: Driver<String>
    let timeText: Driver<String>
    let typeImage: Driver<UIImage?>
    let typeColor: Driver<UIColor?>
    let timeLeftPercent: Driver<Double>
    let repeatButtonClick: Driver<Void>
    let repeatButtonIsHidden: Driver<Bool>
    let hideCell: Driver<Bool>
    let reloadDataSource: Driver<Void>
  }
  
  //MARK: - Init
  init(services: AppServices, task: Task) {
    self.services = services
    self.task = task
  }
  
  func transform(input: Input) -> Output {
    
    let text = Driver<String>.just(self.task.text)
    let typeImage = Driver<UIImage?>.just(self.task.type?.image)
    let typeColor = Driver<UIColor?>.just(self.task.type?.imageColor)
    
    let timer = Observable<Int>.timer(RxTimeInterval.microseconds(1000000 - Int(CACurrentMediaTime().truncatingRemainder(dividingBy: 1) * 1000000)), period: RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
    
    let secondsLeftTimeIntervalSince1970 = timer
      .filter{ _ in self.isEnabled }
      .map { _ in
        return max(self.task.createdTimeIntervalSince1970 - Date().timeIntervalSince1970 + 24 * 60 * 60 , 0) }
      .startWith( max(self.task.createdTimeIntervalSince1970 - Date().timeIntervalSince1970 + 24 * 60 * 60, 0) )
    
    let reloadDataSource = secondsLeftTimeIntervalSince1970.map{ secondsLeft -> () in
      if secondsLeft == 0 { return }
    }.asDriver(onErrorJustReturn: ())
    
    let timeText = secondsLeftTimeIntervalSince1970
      .map{ secondsLeftTimeIntervalSince1970 -> String in
      let time = Date(timeIntervalSince1970: secondsLeftTimeIntervalSince1970)
      return self.formatter.string(from: time)
    }.asDriver(onErrorJustReturn: "")
    
    let timeLeftPercent = secondsLeftTimeIntervalSince1970
      .map{ seconds in
        return self.task.status == .created ? seconds / (24 * 60 * 60) : 0 }
      .asDriver(onErrorJustReturn: 0)
    
    let repeatButtonIsHidden = timeLeftPercent
      .map{ return $0 > 0 }
    
    let repeatButton = input.repeatButtonClickTrigger
      .map {
        self.task.status = .created
        self.task.createdTimeIntervalSince1970 = Date().timeIntervalSince1970
        self.task.closedTimeIntervalSince1970 = nil
        self.services.coreDataService.saveTasksToCoreData(tasks: [self.task], completion: nil)
      }
      
    let hideCell = services.coreDataService.taskRemovingIsRequired
      .map{ task -> Bool in
        return task == nil }
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: false)

    return Output (
      text: text,
      timeText: timeText,
      typeImage: typeImage,
      typeColor: typeColor,
      timeLeftPercent: timeLeftPercent,
      repeatButtonClick: repeatButton,
      repeatButtonIsHidden: repeatButtonIsHidden,
      hideCell: hideCell,
      reloadDataSource: reloadDataSource
    )
  }
}

extension TaskListCollectionViewCellModel: SwipeCollectionViewCellDelegate {
  
  func collectionView(_ collectionView: UICollectionView, willBeginEditingItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) {
    isEnabled = false
  }
  
  func collectionView(_ collectionView: UICollectionView, didEndEditingItemAt indexPath: IndexPath?, for orientation: SwipeActionsOrientation) {
    isEnabled = true
  }
  
  func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
    
    guard orientation == .right else { return nil }
    
    let deleteAction = SwipeAction(style: .destructive, title: nil) { [weak self] action, indexPath in
      guard let self = self else { return }
      action.fulfill(with: .reset)
      
      if self.task.status == .deleted {
        self.services.coreDataService.removeTasksFromCoreData(tasks: [self.task], completion: nil)
      } else {
        self.services.coreDataService.taskRemovingIsRequired.accept(self.task)
      }
    }
    
    let ideaBoxAction = SwipeAction(style: .default, title: nil) { [weak self] action, indexPath in
      guard let self = self else { return }
      action.fulfill(with: .reset)
      self.task.status = .idea
      self.services.coreDataService.saveTasksToCoreData(tasks: [self.task]) { error in
        if let error = error {
          print(error.localizedDescription)
          return
        }
      }
    }
    
    let completeTaskAction = SwipeAction(style: .default, title: nil) { [weak self] action, indexPath in
      guard let self = self else { return }
      action.fulfill(with: .reset)
      self.task.status = .completed
      self.task.closedTimeIntervalSince1970 = Date().timeIntervalSince1970
      self.services.coreDataService.saveTasksToCoreData(tasks: [self.task]) { error in
          if let error = error {
            print(error.localizedDescription)
            return
          }
      }
    }
    
    configure(action: deleteAction, with: .trash)
    configure(action: ideaBoxAction, with: .idea)
    configure(action: completeTaskAction, with: .complete)
    
    deleteAction.backgroundColor = UIColor(named: "appBackground")
    ideaBoxAction.backgroundColor = UIColor(named: "appBackground")
    completeTaskAction.backgroundColor = UIColor(named: "appBackground")
    
    return [completeTaskAction, deleteAction, ideaBoxAction]
  }
  
  func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
    var options = SwipeOptions()
    options.expansionStyle = .destructive
    options.transitionStyle = .border
    options.buttonSpacing = 4
    return options
  }
  
  func configure(action: SwipeAction, with descriptor: ActionDescriptor) {
    let buttonDisplayMode: ButtonDisplayMode = .imageOnly
    let buttonStyle: ButtonStyle = .circular
    
    action.title = descriptor.title(forDisplayMode: buttonDisplayMode)
    action.image = descriptor.image(forStyle: buttonStyle, displayMode: buttonDisplayMode, size: CGSize(width: 44, height: 44))
    
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

