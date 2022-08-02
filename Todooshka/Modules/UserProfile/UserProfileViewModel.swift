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

enum DataSourceType {
  case Initial, Past, Future
}

class UserProfileViewModel: Stepper {
  
  // MARK: - Typealias
  public typealias DisplayCollectionViewCellEvent = (cell: UICollectionViewCell, at: IndexPath)
  
  // MARK: - Public properties
  public let steps = PublishRelay<Step>()
  
  // MARK: - Private properties
  private let services: AppServices
  
  // Calendar
  private let selectedDate = BehaviorRelay<Date>(value: Date())
  private let selectedMonthComponents = BehaviorRelay<[Int]>(value: [-2,-1,0,1])
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
    let selectionHandler: Driver<CalendarDay>
    // dataSource
    let dataSource: Driver<[CalendarSectionModel]>
    let willDisplayCell: Driver<Void>
    let scrollToCurrentMonth: Driver<(trigger: Bool, withAnimation: Bool)>
  }
  
  func appendPastData() {
    self.selectedMonthComponents.accept(
      [self.selectedMonthComponents.value.min()! - 1] +
      self.selectedMonthComponents.value)
  }
  
  func appendFutureData() {
    self.selectedMonthComponents.accept(
      self.selectedMonthComponents.value +
      [self.selectedMonthComponents.value.max()! + 1])
  }
  
  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }
  
  //MARK: - Transform
  func transform(input: Input) -> Output {
    
    // caledar
    let selectedDate = selectedDate.asDriver()
    let selectedMonthComponents = selectedMonthComponents.asDriver()
    
    // completed tasks
    let completedTasks = services.tasksService
      .tasks
      .map { $0.filter {
        $0.status == .Completed && $0.closed != nil
      }}
      .asDriver(onErrorJustReturn: [])
    
    // dataSource
    let dataSource = Driver<([CalendarSectionModel])>
      .combineLatest(selectedMonthComponents, selectedDate, completedTasks) { selectedMonthComponents, selectedDate, completedTasks -> [CalendarSectionModel] in
        selectedMonthComponents.map { monthComponent -> CalendarSectionModel in
          let date = Date().adding(.month, value: monthComponent)
          let daysInMonth = Calendar.current.numberOfDaysInMonth(for: date)
          var items: [CalendarDay] = []
    
          let addDaysBeforeStartOfMonth = self.addDaysBeforeStartOfMonth(date: date)
          
          if addDaysBeforeStartOfMonth > 0 {
            for _ in 0 ... addDaysBeforeStartOfMonth - 1 {
              items.append(CalendarDay(
                date: date,
                isSelected: false,
                completedTasksCount: 0,
                isEnabled: false))
            }
          }
   
          for dayComponent in 0 ... daysInMonth - 1 {
            let day = date.startOfMonth.adding(.day, value: dayComponent)
            items.append(CalendarDay(
              date: day,
              isSelected: Calendar.current.isDate(day, inSameDayAs: selectedDate),
              completedTasksCount: completedTasks.filter { Calendar.current.isDate($0.closed!, inSameDayAs: day) }.count,
              isEnabled: true))
          }
                    
          return CalendarSectionModel(
            type: .Month,
            year: date.year,
            month: date.month,
            items: items)
        }
      }
      .asDriver()
    
   
    let scrollToCurrentMonth = services.preferencesService
      .scrollToCurrentMonthTrigger
      .asDriver()

    // selection
    let selectionHandler = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource -> CalendarDay? in
        if dataSource[indexPath.section].type == .Year || dataSource[indexPath.section].items[indexPath.item].isEnabled == false { return nil }
        return dataSource[indexPath.section].items[indexPath.item]
      }.compactMap { $0 }
      .do { day in
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
    
    let willDisplayCell = input.willDisplayCell
      .map { event -> Int in
        event.at.section
      }.distinctUntilChanged() 
      .withLatestFrom(dataSource) { section, dataSource -> Void in
        if section == dataSource.count - 1 {
          print("1234 append future")
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
      selectionHandler: selectionHandler,
      // dataSource
      dataSource: dataSource,
      willDisplayCell: willDisplayCell,
      scrollToCurrentMonth: scrollToCurrentMonth
    )
  }
  
  func addDaysBeforeStartOfMonth(date: Date) -> Int {
    switch date.weekday {
    case 1:
      return 6
    case 2 ... 7:
      return date.weekday - 2
    default:
      return -1
    }
  }
}

