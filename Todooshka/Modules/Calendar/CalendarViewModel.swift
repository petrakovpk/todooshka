//
//  CalendarViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import RxFlow
import RxSwift
import RxCocoa
import CoreData

enum DataSourceType {
  case Initial, Past, Future
}

class CalendarViewModel: Stepper {
  
  // MARK: - Typealias
  public typealias DisplayCollectionViewCellEvent = (cell: UICollectionViewCell, at: IndexPath)
  
  // MARK: - Public properties
  public let steps = PublishRelay<Step>()
  
  // MARK: - Private properties
  let services: AppServices
  
  // Calendar
  private let dataSourceMonths = BehaviorRelay<[Date]>(value: [
    Date().adding(.month, value: -2).startOfMonth,
    Date().adding(.month, value: -1).startOfMonth,
    Date().startOfMonth,
    Date().adding(.month, value: 1).startOfMonth
  ])
  
  private var dataSourceType: DataSourceType = .Initial
  
  struct Input {
    // buttons
    let settingsButtonClickTrigger: Driver<Void>
    let shopButtonClickTrigger: Driver<Void>
    // game currency
    let featherBackgroundViewClickTrigger: Driver<Void>
    let diamondBackgroundViewClickTrigger: Driver<Void>
    // selection
    let selection: Driver<IndexPath>
    // willDisplayCell
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
    let openTaskList: Driver<Void>
    let saveSelectedDate: Driver<Void>
    // dataSource
    let dataSource: Driver<[CalendarSection]>
    let willDisplayCell: Driver<Void>
    let scrollToCurrentMonth: Driver<(trigger: Bool, withAnimation: Bool)>
  }
  
  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  //MARK: - Transform
  func transform(input: Input) -> Output {
    
    // caledar
    let selectedDate = services.dataService.selectedDate.asDriver()
    let dataSourceMonths = dataSourceMonths.asDriver()
    
    // completed tasks
    let completedTasks = services.dataService
      .tasks
      .map { $0.filter { $0.status == .Completed }}
      .map { $0.filter { $0.closed != nil }}
      .asDriver(onErrorJustReturn: [])
    
    
    let dataSource = Driver<[CalendarSection]>
      .combineLatest(dataSourceMonths, selectedDate, completedTasks) { dataSourceMonths, selectedDate, completedTasks -> [CalendarSection] in
        dataSourceMonths.map { startOfMonth -> CalendarSection in
          CalendarSection(
            type: .Month(startOfMonth: startOfMonth) ,
            items:
              // пустые дни
            self.emptyDays(date: startOfMonth)
              .countableRange
              .map { _ in CalendarItem(type: .Empty) } +
            // нормальные дни
            Calendar.current.numberOfDaysInMonth(for: startOfMonth)
              .countableRange
              .map { startOfMonth.adding(.day, value: $0) }
              .map { date -> CalendarItem in
                CalendarItem(type: .Day(
                  date: date,
                  isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate) ,
                  completedTasksCount: completedTasks.filter{ Calendar.current.isDate($0.closed!, inSameDayAs: date) }.count
                ))
              }
          )
        }
      }
    
    let scrollToCurrentMonth = services.preferencesService
      .scrollToCurrentMonthTrigger
      .asDriver()
    
    // selection
    let selectionHandler = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource -> Date? in
        switch dataSource[indexPath.section].items[indexPath.item].type {
        case .Empty:
          return nil
        case .Day(let date, _, _):
          return date
        }
      }
      .compactMap { $0 }
      .startWith(Date())
    
    let openTaskList = selectionHandler
      .withLatestFrom(selectedDate) { date, selectedDate -> Date? in
        date == selectedDate ? date : nil
      }.compactMap{ $0 }
      .map { $0 > Date() ? AppStep.PlannedTaskListIsRequired(date: $0) : AppStep.CompletedTaskListIsRequired(date: $0) }
      .map { self.steps.accept($0) }
    
    let saveSelectedDate = selectionHandler
      .withLatestFrom(selectedDate) { date, selectedDate -> Date? in
        date == selectedDate ? nil : date
      }.compactMap{ $0 }
      .map { self.services.dataService.selectedDate.accept($0) }
   
    // score
    let featherScoreLabel = services.dataService.feathersCount
      .map{ $0.string }
      .asDriver(onErrorJustReturn: "")
    
    let diamondScoreLabel = services.dataService.diamonds
      .map{ $0.count.string }
      .asDriver(onErrorJustReturn: "")
    
    // buttons
    let featherBackgroundViewClickHandler = input.featherBackgroundViewClickTrigger
      .map { self.steps.accept(AppStep.FeatherIsRequired) }
    
    let diamondBackgroundViewClickHandler = input.diamondBackgroundViewClickTrigger
      .map { self.steps.accept(AppStep.DiamondIsRequired) }
    
    let settingsButtonClicked = input.settingsButtonClickTrigger
      .map { self.steps.accept(AppStep.SettingsIsRequired) }
    
    let shopButtonClicked = input.shopButtonClickTrigger
      .map { self.steps.accept(AppStep.ShopIsRequired) }
    
    let willDisplayCell = input.willDisplayCell
      .map { $0.at.section }
      .distinctUntilChanged()
      .withLatestFrom(dataSource) { section, dataSource -> Void in
        if section == dataSource.count - 1 {
          self.appendFutureData()
        }
      }
    
    
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
      openTaskList: openTaskList,
      saveSelectedDate: saveSelectedDate,
      // dataSource
      dataSource: dataSource,
      willDisplayCell: willDisplayCell,
      scrollToCurrentMonth: scrollToCurrentMonth
    )
  }
  
  func appendPastData() {
    self.dataSourceMonths.accept(
      [ self.dataSourceMonths.value.min()!.adding(.month, value: -1) ]
      + self.dataSourceMonths.value
    )
  }
  
  func appendFutureData() {
    self.dataSourceMonths.accept(
      self.dataSourceMonths.value +
      [ self.dataSourceMonths.value.max()!.adding(.month, value: 1) ]
    )
  }
  
  func emptyDays(date: Date) -> Int {
    switch date.weekday {
    case 1: return 7 - 1
    case 2 ... 7: return date.weekday - 1 - 1
    default: return -1
    }
  }
}

