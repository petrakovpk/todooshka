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

class TaskListCellModel: Stepper {
  
  // MARK: - Properties
  let services: AppServices
  let steps = PublishRelay<Step>()
  var task: Task
  
  var isEnabled: Bool = true
  
  let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH'h' mm'm' ss's'"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
  }()
  
  struct Input {
    let repeatButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    // text
    let text: Driver<String>
    // description
    let description: Driver<String>
    // type
    let type: Driver<TaskType>
    // time Left
    let taskTimeLeftViewIsHidden: Driver<Bool>
    let timeLeftText: Driver<String>
    let timeLeftPercent: Driver<Double>
    // Repeat Button
    let repeatButtonClick: Driver<Void>
    let repeatButtonIsHidden: Driver<Bool>
    // actions
    let isHidden: Driver<Bool>
    // dataSource
    let reloadDataSource: Driver<Void>
  }
  
  //MARK: - Init
  init(services: AppServices, task: Task) {
    self.services = services
    self.task = task
  }
  
  func transform(input: Input) -> Output {
    // text
    let text = Driver<String>.just(task.text)
    
    // description
    let description = Driver<String>.just(task.description ?? "")
    
    // type
    let type = Driver<TaskType>.just(
      self.services.typesService.types.value.first{ $0.UID == self.task.typeUID } ?? .Standart.Empty
    )
    
    // timer
    let timer = Observable<Int>
      .timer(
        RxTimeInterval.microseconds(1000000 - Int(CACurrentMediaTime().truncatingRemainder(dividingBy: 1) * 1000000)),
        period: RxTimeInterval.seconds(1),
        scheduler: MainScheduler.instance
      )
      .filter { _ in self.isEnabled }
    
    // timeLeftText
    let timeLeftText = timer
      .map { _ in self.task.secondsLeftText }
      .startWith( task.secondsLeftText )
      .asDriver(onErrorJustReturn: "")
    
    // timeLeftPercent
    let timeLeftPercent = timer
      .map { _ in self.task.status == .InProgress ? self.task.secondsLeft / (24 * 60 * 60) : 0 }
      .asDriver(onErrorJustReturn: 0)
    
    // repeatButtonIsHidden
    let repeatButtonIsHidden = Driver<Bool>.just(self.repeatButtonIsHidden(task: self.task))
    
    // taskTimeLeftViewIsHidden
    let taskTimeLeftViewIsHidden = repeatButtonIsHidden
      .map { !$0 }
    
    // repeatButton
    let repeatButton = input.repeatButtonClickTrigger
      .do { _ in
        self.task.status = .InProgress
        self.task.created = Date()
        self.task.closed = nil
        self.task.planned = nil
      }
      .do { _ in
        
        // сохраняем таску
        self.services.tasksService.saveTasksToCoreData(tasks: [self.task])
        
      }
    
    // isHidden
    let isHidden = services.tasksService.removeTrigger
      .map { removeMode -> Bool in
        if case .Task(_) = removeMode { return false } else { return true }
      }
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: false)
    
    // Mode
    let reloadDataSource = timer
      .map { _ -> () in
        if self.task.secondsLeft == 0 { return }
      }.asDriver(onErrorJustReturn: ())
    
    return Output (
      // text
      text: text,
      // desccription
      description: description,
      // type
      type: type,
      // time Left
      taskTimeLeftViewIsHidden: taskTimeLeftViewIsHidden,
      timeLeftText: timeLeftText,
      timeLeftPercent: timeLeftPercent,
      // repeat button
      repeatButtonClick: repeatButton,
      repeatButtonIsHidden: repeatButtonIsHidden,
      // actions
      isHidden: isHidden,
      // dataSource
      reloadDataSource: reloadDataSource
    )
  }
  
  // MARK: - Helpers
  func repeatButtonIsHidden(task: Task) -> Bool {
    switch task.status {
    case .Idea, .Deleted, .Completed:
      return false
    default:
      return task.is24hoursPassed == false
    }
  }
}

extension TaskListCellModel: SwipeCollectionViewCellDelegate {
  
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
      
      if self.task.status == .Deleted {
        self.services.tasksService.removeTasksFromCoreData(tasks: [self.task])
      } else {
        self.services.tasksService.removeTrigger.accept(.Task(task: self.task))
      }
    }
    
    let ideaBoxAction = SwipeAction(style: .default, title: nil) { [weak self] action, indexPath in
      guard let self = self else { return }
      action.fulfill(with: .reset)
      self.task.status = .Idea
      self.services.tasksService.saveTasksToCoreData(tasks: [self.task])
      self.services.actionService.runMainTaskListActionsTrigger.accept(())
    }
    
    let completeTaskAction = SwipeAction(style: .default, title: nil) { [weak self] action, indexPath in
      guard let self = self else { return }
      action.fulfill(with: .reset)
      self.task.status = .Completed
      self.task.closed = Date()
      
      // сохраняем яйцо
      self.services.tasksService.saveTasksToCoreData(tasks: [self.task])
      
      // получаем очко
      self.services.gameCurrencyService.createGameCurrency(task: self.task)
    }
    
    configure(action: deleteAction, with: .trash)
    configure(action: ideaBoxAction, with: .idea)
    configure(action: completeTaskAction, with: .complete)
    
    deleteAction.backgroundColor = Theme.App.background
    ideaBoxAction.backgroundColor = Theme.App.background
    completeTaskAction.backgroundColor = Theme.App.background
    
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

