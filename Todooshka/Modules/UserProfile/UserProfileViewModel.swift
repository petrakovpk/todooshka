//
//  UserProfileViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import RxFlow
import RxSwift
import RxCocoa
import CoreData

class UserProfileViewModel: Stepper {
  
  // MARK: - Properties
  let steps = PublishRelay<Step>()
  private let services: AppServices
  
  // Calendar
  private let selected = BehaviorRelay<Date>(value: Date())
  private let months = BehaviorRelay<[Int]>(value: [-1, 0, 1])
  
  struct Input {
    // buttons
    let settingsButtonClickTrigger: Driver<Void>
    let shopButtonClickTrigger: Driver<Void>
    // game currency
    let featherBackgroundViewClickTrigger: Driver<Void>
    let diamondBackgroundViewClickTrigger: Driver<Void>
    // selection
    let selection: Driver<IndexPath>
  }
  
  struct Output {
    // buttons
    let settingsButtonClickHandler: Driver<Void>
    let shopButtonClickHandler: Driver<Void>
    // score
    let featherScoreLabel: Driver<String>
    let diamondScoreLabel: Driver<String>
    let featherBackgroundViewClickHandler: Driver<Void>
    let diamondBackgroundViewClickHandler: Driver<Void>
    // selection
    let selectionHandler: Driver<CalendarDay>
    // dataSource
    let dataSource: Driver<[CalendarSectionModel]>
  }
  
  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  //MARK: - Transform
  func transform(input: Input) -> Output {
    // caledar
    let months = months.asDriver()
    let selected = selected.asDriver()
    
    // completed tasks
    let completedTasks = services.tasksService
      .tasks
      .map {
        $0.filter {
          $0.status == .Completed
        }
      }
      .asDriver(onErrorJustReturn: [])
    
    // dataSource
    let dataSource = Driver<[CalendarSectionModel]>
      .combineLatest(months, selected, completedTasks) { months, selected, completedTasks -> [CalendarSectionModel] in
        var result: [CalendarSectionModel] = []
        
        for month in months {
          var days: [CalendarDay] = []
          let start = Date()
            .adding(.month, value: month)
            .startOfMonth
          
          for delta in 0...Calendar.current.numberOfDaysInMonth(for: start) - 1 {
            let date = start.adding(.day, value: delta)
            let completedTasks = completedTasks
              .filter { task -> Bool in
                guard let closed = task.closed else { return false }
                return Calendar.current.isDate(closed, inSameDayAs: date)
              }
            
            days.append(
              CalendarDay(
                date: date,
                isSelected: Calendar.current.isDate(date, inSameDayAs: selected),
                completedTasksCount: completedTasks.count
              ))
          }
          
          result.append(CalendarSectionModel(header: start.monthName(), items: days))
        }
        
        return result
      }.asDriver()
      .debug()
    
    // selection
    let selectionHandler = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource -> CalendarDay in
        return dataSource[indexPath.section].items[indexPath.item]
      }
      .do { day in
        self.selected.value == day.date ? self.steps.accept(AppStep.CompletedTaskListIsRequired(date: day.date)) : self.selected.accept(day.date)
      }
    
    // score
    let featherScoreLabel = services.gameCurrencyService.gameCurrency
      .map {
        $0.filter {
          $0.currency == .Feather
        }
        .count
        .string
      }
      .asDriver(onErrorJustReturn: "")
    
    let diamondScoreLabel = services.gameCurrencyService.gameCurrency
      .map {
        $0.filter {
          $0.currency == .Diamond
        }
        .count
        .string
      }.asDriver(onErrorJustReturn: "")
    
    
    // buttons
    let featherBackgroundViewClickHandler = input.featherBackgroundViewClickTrigger
      .do { _ in self.steps.accept(AppStep.FeatherIsRequired) }
    
    let diamondBackgroundViewClickHandler = input.diamondBackgroundViewClickTrigger
      .do { _ in self.steps.accept(AppStep.DiamondIsRequired) }

    let settingsButtonClicked = input.settingsButtonClickTrigger
      .do { _ in self.steps.accept(AppStep.UserSettingsIsRequired) }
    
    let shopButtonClicked = input.shopButtonClickTrigger
      .do { _ in self.steps.accept(AppStep.ShopIsRequired) }
    
    return Output(
      // buttons
      settingsButtonClickHandler: settingsButtonClicked,
      shopButtonClickHandler: shopButtonClicked,
      //  пфьу сгккутсн
      featherScoreLabel: featherScoreLabel,
      diamondScoreLabel: diamondScoreLabel,
      featherBackgroundViewClickHandler: featherBackgroundViewClickHandler,
      diamondBackgroundViewClickHandler: diamondBackgroundViewClickHandler,
      // selection
      selectionHandler: selectionHandler,
      // dataSource
      dataSource: dataSource
    )
  }
}

