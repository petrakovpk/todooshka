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

// enum DataSourceType {
//  case initial, past, future
// }

class OldCalendarViewModel: Stepper {
  // MARK: - Typealias
 // public typealias DisplayCollectionViewCellEvent = (cell: UICollectionViewCell, at: IndexPath)

  // MARK: - Public properties
  public let steps = PublishRelay<Step>()

  // MARK: - Private properties
  let services: AppServices

  // Calendar
//  private let dataSourceMonths = BehaviorRelay<[Date]>(value: [
//    Date().adding(.month, value: -2).startOfMonth,
//    Date().adding(.month, value: -1).startOfMonth,
//    Date().startOfMonth,
//    Date().adding(.month, value: 1).startOfMonth
//  ])

//  private var dataSourceType: DataSourceType = .initial

  struct Input {
    // buttons
  //  let settingsButtonClickTrigger: Driver<Void>
    // let shopButtonClickTrigger: Driver<Void>
    // game currency
//    let featherBackgroundViewClickTrigger: Driver<Void>
//    let diamondBackgroundViewClickTrigger: Driver<Void>
    // selection
    let selection: Driver<IndexPath>
    // willDisplayCell
  //  let willDisplayCell: Driver<DisplayCollectionViewCellEvent>
  }

  struct Output {
    // buttons
//    let settingsButtonClickHandler: Driver<Void>
//    let shopButtonClickHandler: Driver<Void>
//    // score
//    let featherScoreLabel: Driver<String>
//    let diamondScoreLabel: Driver<String>
//    let featherBackgroundViewClickHandler: Driver<Void>
//    let diamondBackgroundViewClickHandler: Driver<Void>
    // selection
    let selectedDate: Driver<Date>
  //  let saveSelectedDate: Driver<Void>
    // dataSource
    let dataSource: Driver<[CalendarSection]>
//    let willDisplayCell: Driver<Void>
//    let scrollToCurrentMonth: Driver<(trigger: Bool, withAnimation: Bool)>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  // MARK: - Transform
  func transform(input: Input) -> Output {
    
    // MARK: - DATASOURCE
    let dataSource = Driver<[CalendarSection]>.of([])
    
    let selectedDate = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource -> CalendarItem in
        dataSource[indexPath.section].items[indexPath.item]
      }
      .map { $0.date }
      .do { self.services.dataService.selectedDate.accept($0) }
    
//    let selected = services.dataService.selectedDate.asDriver()
//    let dataSourceMonths = dataSourceMonths.asDriver()
//
//    // completed tasks
//    let completedTasks = services.dataService
//      .tasks
//      .map { $0.filter { $0.status == .completed } }
//      .map { $0.filter { $0.completed != nil } }
//      .asDriver(onErrorJustReturn: [])
//
//    let plannedTasks = services.dataService
//      .tasks
//      .map { $0.filter { $0.status == .inProgress } }
//      .map { $0.filter { $0.planned != nil } }
//      .asDriver(onErrorJustReturn: [])
//
//    let dataSource = Driver<[CalendarSection]>
//      .combineLatest(dataSourceMonths, selectedDate, completedTasks, plannedTasks) { dataSourceMonths, selectedDate, completedTasks, plannedTasks -> [CalendarSection] in
//        dataSourceMonths.map { startOfMonth -> CalendarSection in
//          CalendarSection(
//            type: .month(startOfMonth: startOfMonth),
//            items:
//              // пустые дни
//            self.emptyDays(date: startOfMonth)
//              .countableRange
//              .map { _ in CalendarItem(type: .empty) } +
//            // нормальные дни
//            Calendar.current.numberOfDaysInMonth(for: startOfMonth)
//              .countableRange
//              .map { startOfMonth.adding(.day, value: $0) }
//              .map { date -> CalendarItem in
//                CalendarItem(type: .day(
//                  date: date,
//                  isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
//                  completedTasksCount: completedTasks.filter { Calendar.current.isDate($0.completed!, inSameDayAs: date) }.count,
//                  plannedTasksCount: plannedTasks.filter { Calendar.current.isDate($0.planned, inSameDayAs: date) }.count
//                ))
//              }
//          )
//        }
//      }
//
//    let scrollToCurrentMonth = services.preferencesService
//      .scrollToCurrentMonthTrigger
//      .asDriver()
//
//    // selection
//    let selectionHandler = input.selection
//      .withLatestFrom(dataSource) { indexPath, dataSource -> Date? in
//        switch dataSource[indexPath.section].items[indexPath.item].type {
//        case .empty:
//          return nil
//        case .day(let date, _, _, _):
//          return date
//        }
//      }
//      .compactMap { $0 }
//      .startWith(Date())
//
//    let openTaskList = selectionHandler
//      .withLatestFrom(selectedDate) { date, selectedDate -> Date? in
//        date == selectedDate ? date : nil
//      }.compactMap { $0 }
//      .map { $0 > Date() ? AppStep.plannedTaskListIsRequired(date: $0) : AppStep.completedTaskListIsRequired(date: $0) }
//      .map { self.steps.accept($0) }
//
//    let saveSelectedDate = selectionHandler
//      .withLatestFrom(selectedDate) { date, selectedDate -> Date? in
//        date == selectedDate ? nil : date
//      }.compactMap { $0 }
//      .map { self.services.dataService.selectedDate.accept($0) }
//
//    // score
//    let featherScoreLabel = services.dataService.feathersCount
//      .map { $0.string }
//      .asDriver(onErrorJustReturn: "")
//
//    let diamondScoreLabel = services.dataService.diamonds
//      .map { $0.count.string }
//      .asDriver(onErrorJustReturn: "")
//
//    // buttons
//    let featherBackgroundViewClickHandler = input.featherBackgroundViewClickTrigger
//      .map { self.steps.accept(AppStep.featherIsRequired) }
//
//    let diamondBackgroundViewClickHandler = input.diamondBackgroundViewClickTrigger
//      .map { self.steps.accept(AppStep.diamondIsRequired) }
//
//    let settingsButtonClicked = input.settingsButtonClickTrigger
//      .map { self.steps.accept(AppStep.settingsIsRequired) }
//
//    let shopButtonClicked = input.shopButtonClickTrigger
//      .map { self.steps.accept(AppStep.shopIsRequired) }
//
//    let willDisplayCell = input.willDisplayCell
//      .map { $0.at.section }
//      .distinctUntilChanged()
//      .withLatestFrom(dataSource) { section, dataSource -> Bool in
//        section == dataSource.count - 1
//      }
//      .filter { $0 }
//      .map { _ in self.appendFutureData() }

    return Output(
      // buttons
//      settingsButtonClickHandler: settingsButtonClicked,
//      shopButtonClickHandler: shopButtonClicked,
//      //  пфьу сгккутсн
//      featherScoreLabel: featherScoreLabel,
//      diamondScoreLabel: diamondScoreLabel,
//      featherBackgroundViewClickHandler: featherBackgroundViewClickHandler,
//      diamondBackgroundViewClickHandler: diamondBackgroundViewClickHandler,
      // selection
      selectedDate: selectedDate,
     // saveSelectedDate: saveSelectedDate,
      // dataSource
      dataSource: dataSource
     // willDisplayCell: willDisplayCell,
     // scrollToCurrentMonth: scrollToCurrentMonth
    )
  }
//
//  func appendPastData() {
//    self.dataSourceMonths.accept(
//      [ self.dataSourceMonths.value.min()!.adding(.month, value: -1) ]
//      + self.dataSourceMonths.value
//    )
//  }
//
//  func appendFutureData() {
//    self.dataSourceMonths.accept(
//      self.dataSourceMonths.value +
//      [ self.dataSourceMonths.value.max()!.adding(.month, value: 1) ]
//    )
//  }
//
//  func emptyDays(date: Date) -> Int {
//    switch date.weekday {
//    case 1: return 7 - 1
//    case 2 ... 7: return date.weekday - 1 - 1
//    default: return -1
//    }
//  }
}
