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
  
  // MARK: - Typealias
  public typealias DisplayCollectionViewCellEvent = (cell: UICollectionViewCell, at: IndexPath)
  
  // MARK: - Public properties
  public let steps = PublishRelay<Step>()
  public let scrollToCurrentMonth = BehaviorRelay<Void?>(value: nil)
  
  // MARK: - Private properties
  private let services: AppServices
  
  // Calendar
  private let selectedDate = BehaviorRelay<Date>(value: Date())
  private let years = BehaviorRelay<[Int]>(value: [Date().year])
 // private let months = BehaviorRelay<[Int]>(value: [-2,-1,0,1,2,3])
  
  struct Input {
    // buttons
    let settingsButtonClickTrigger: Driver<Void>
    let shopButtonClickTrigger: Driver<Void>
    // game currency
    let featherBackgroundViewClickTrigger: Driver<Void>
    let diamondBackgroundViewClickTrigger: Driver<Void>
    // selection
    let selection: Driver<IndexPath>
    //
    let willDisplayCell: Driver<DisplayCollectionViewCellEvent>
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
  //  let addMonth: Driver<Void>
    let scrollToCurrentMonth: Driver<IndexPath>
  }
  
  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  //MARK: - Transform
  func transform(input: Input) -> Output {
    
    // caledar
    let years = years.asDriver()
    let selectedDate = selectedDate.asDriver()
    
    // completed tasks
    let completedTasks = services.tasksService
      .tasks
      .map { $0.filter {
        $0.status == .Completed && $0.closed != nil
      }}
      .asDriver(onErrorJustReturn: [])
    
    // dataSource
    let dataSource = Driver<[CalendarSectionModel]>
      .combineLatest(years, selectedDate, completedTasks) { years, selectedDate, completedTasks -> [CalendarSectionModel] in
        years.map { year -> [CalendarSectionModel] in
          var result: [CalendarSectionModel] = [CalendarSectionModel(type: .Year, year: year, month: 1, items: [])]
          for month in 1...12 {
            guard let firstDayOfMonth = Calendar.current.date(from: DateComponents(year: year, month: month, day: 1)) else { continue }
            let daysCountInMonth = Calendar.current.numberOfDaysInMonth(for: firstDayOfMonth)
            var calendarSectionModel = CalendarSectionModel(type: .Month, year: year, month: month, items: [])
            for dayNumber in 1 ... daysCountInMonth {
              let day = firstDayOfMonth.adding(.day, value: dayNumber - 1)
              calendarSectionModel.items.append(
                CalendarDay(
                  date: day,
                  isSelected: Calendar.current.isDate(day, inSameDayAs: selectedDate),
                  completedTasksCount: completedTasks.filter { Calendar.current.isDate($0.closed!, inSameDayAs: day) }.count
                )
              )
            }
            result.append(calendarSectionModel)
          }
          return result
        }.flatMap{ $0 }
      }.asDriver()
    
    let currentMonthIndexPath = dataSource
      .map { models -> IndexPath in
        let item = 0
        let section = models.firstIndex(where: { $0.year == Date().year && $0.month == Date().month }) ?? 0
        return IndexPath(item: item, section: section)
      }
    
    let scrollToCurrentMonth = scrollToCurrentMonth
      .asDriver(onErrorJustReturn: nil)
      .filter{ _ in self.services.preferencesService.needScrollToCurrentMonth }
      .compactMap{ $0 }
      .withLatestFrom(currentMonthIndexPath) { $1 }
      .do { _ in self.services.preferencesService.needScrollToCurrentMonth = false }
    
    // selection
    let selectionHandler = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource -> CalendarDay in
        return dataSource[indexPath.section].items[indexPath.item]
      }.do { day in
        self.selectedDate.value == day.date ? self.steps.accept(AppStep.CompletedTaskListIsRequired(date: day.date)) : self.selectedDate.accept(day.date)
      }
    
    // score
    let featherScoreLabel = services.gameCurrencyService.gameCurrency
      .map { $0.filter {
        $0.currency == .Feather }
      .count
        .string }
      .asDriver(onErrorJustReturn: "")
    
    let diamondScoreLabel = services.gameCurrencyService.gameCurrency
      .map { $0.filter {
        $0.currency == .Diamond }
      .count
        .string }
      .asDriver(onErrorJustReturn: "")
    
    
    // buttons
    let featherBackgroundViewClickHandler = input.featherBackgroundViewClickTrigger
      .do { _ in self.steps.accept(AppStep.FeatherIsRequired) }
    
    let diamondBackgroundViewClickHandler = input.diamondBackgroundViewClickTrigger
      .do { _ in self.steps.accept(AppStep.DiamondIsRequired) }
    
    let settingsButtonClicked = input.settingsButtonClickTrigger
      .do { _ in self.steps.accept(AppStep.UserSettingsIsRequired) }
    
    let shopButtonClicked = input.shopButtonClickTrigger
      .do { _ in self.steps.accept(AppStep.ShopIsRequired) }
    
//    let addMonthAfter = input.willDisplayCell.withLatestFrom(dataSource) { cellEvent, dataSource -> Int in
//      return dataSource[cellEvent.at.section].items[cellEvent.at.item].date.month - Date().month }
//      .withLatestFrom(months) { monthSelected, months in
//        if monthSelected == months.max() {
//          self.months.accept(self.months.value + [monthSelected + 1, monthSelected + 2])
//        }
//      }
    
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
      dataSource: dataSource,
     // addMonth: addMonthAfter,
      scrollToCurrentMonth: scrollToCurrentMonth
    )
  }
}

