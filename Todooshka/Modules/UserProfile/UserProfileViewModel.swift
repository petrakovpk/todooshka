//
//  UserProfileViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import RxFlow
import RxSwift
import RxCocoa
import Firebase
import CoreData

class UserProfileViewModel: Stepper {
  
  let steps = PublishRelay<Step>()
  // let dataSource = BehaviorRelay<[UserProfileSectionModel]>(value: [])
  let disposeBag = DisposeBag()
  
  // let deltaMonth = BehaviorRelay<Int>(value: 0)
  
  let services: AppServices
  
  struct Input {
    let leftButtonClickTrigger: Driver<Void>
    let rightButtonClickTrigger: Driver<Void>
    let settingsButtonClickTrigger: Driver<Void>
    let selection: Driver<IndexPath>
    let settingsButtonClickedTrigger: Driver<Void>
  }
  
  struct Output {
    let completedTaskCount: Driver<String>
    let completedTaskStatus: Driver<String>
    let monthText: Driver<String>
    
    let dataSource: Driver<[UserProfileSectionModel]>
    
    let selectedCalendarDay: Driver<CalendarDay>
    let settingsButtonClicked: Driver<Void>
    let completedTasksGroupedByType: Driver<[String]>
  }
  
  
  init(services: AppServices) {
    self.services = services
    
    self.services.coreDataService.calendarSelectedDate.accept(Date())
    
  }
  
  //MARK: - Transform
  func transform(input: Input) -> Output {
    
    let previousMonthSelected = input.leftButtonClickTrigger.map { return -1 }
    let nextMonthSelected = input.rightButtonClickTrigger.map { return 1 }
    
    let selectedMonth = Driver.of(previousMonthSelected, nextMonthSelected)
      .merge()
      .startWith(0)
      .scan(Date()) { selectedDate, deltaMonth in
        return selectedDate.adding(.month, value: deltaMonth)
      }
      .asDriver()
    
    let selectedMonthText = selectedMonth.map { date -> String in
      let dateFormatter = DateFormatter()
      dateFormatter.locale = Locale(identifier: "ru_RU")
      dateFormatter.dateFormat = "LLLL"
      var stringDate = dateFormatter.string(from: date)
      stringDate.firstCharacterUppercased()
      return stringDate
    }
    
    let allCompletedTasks = services.coreDataService.tasks
      .map{ $0.filter { $0.status == .completed }}.asDriver(onErrorJustReturn: [])
    
    let selectedDayCompletedTasks = Driver<[Task]>.combineLatest(allCompletedTasks, self.services.coreDataService.calendarSelectedDate.asDriver() ) { tasks, date -> [Task] in
      return tasks.filter { task in
        if let closedDate = task.closedDate {
          return Calendar.current.isDate(date , inSameDayAs: closedDate)
        } else { return false }
      }
    }
    
    let completedTaskCount = selectedDayCompletedTasks.map{ return $0.count.string }
    let completedTaskStatus = selectedDayCompletedTasks.map{ return self.getDayText(tasksCount: $0.count) }
    
    let dataSource = Driver<[UserProfileSectionModel]>
      .combineLatest(allCompletedTasks, selectedMonth) {(tasks, selectedMonth) -> [UserProfileSectionModel] in
        
        let startOfMonthDate = selectedMonth.startOfMonth
        let endOfMonthDate = selectedMonth.endOfMonth
        let startOfMonthWeekday = startOfMonthDate.weekday - 1 == 0 ? 7 : startOfMonthDate.weekday - 1
        let endOfMonthDateWeekday = endOfMonthDate.weekday - 1 == 0 ? 7 : endOfMonthDate.weekday - 1
        let daysInMonth = Calendar.current.numberOfDaysInMonth(for: startOfMonthDate)
        
        var items: [CalendarDay] = []
        
        for i in 0 ..< startOfMonthWeekday - 1 {
          let minusDay = startOfMonthWeekday - 1 - i
          items.append( CalendarDay(date: startOfMonthDate.adding(.day, value: -1 * minusDay), isSelectedMonth: false) )
        }
        
        for i in 0 ... daysInMonth - 1 {
          items.append( CalendarDay(date: startOfMonthDate.adding(.day, value: i), isSelectedMonth: true) )
        }
        
        for i in 0 ..< 7 - endOfMonthDateWeekday {
          let plusDay = i + 1
          items.append( CalendarDay(date: endOfMonthDate.adding(.day, value: plusDay), isSelectedMonth: false) )
        }
        
        if items.count == 5 * 7 {
          for i in 0 ..< 7 {
            let plusDay = i + 8 - endOfMonthDateWeekday
            items.append( CalendarDay(date: endOfMonthDate.adding(.day, value: plusDay), isSelectedMonth: false) )
          }
        }
        
        return [UserProfileSectionModel(header: "", items: items)]
        
      }.asDriver()
    
    let calendarDaySelected = input.selection.withLatestFrom(dataSource) { indexPath, dataSource -> CalendarDay in
      let calendarDate = dataSource[indexPath.section].items[indexPath.item]
      
      if calendarDate.isSelectedMonth {
        calendarDate.date == self.services.coreDataService.calendarSelectedDate.value ? self.steps.accept(AppStep.completedTaskListIsRequired(date: calendarDate.date)) : self.services.coreDataService.calendarSelectedDate.accept(calendarDate.date)
      }
      return calendarDate
    }.asDriver()

    let completedTasksGroupedByType = selectedDayCompletedTasks.map { tasks -> [String] in
      let tasksGroupByTypeDict = Dictionary(grouping: tasks, by: { $0.type?.text ?? "" }).sorted{ $0.value.count > $1.value.count }
      
      var result: [String] = []
      for type in tasksGroupByTypeDict {
        result.append("\(type.key): \(type.value.count)")
      }
      return result
    }
    
    let settingsButtonClicked = input.settingsButtonClickedTrigger
      .map{ self.steps.accept(AppStep.userSettingsIsRequired) }
  
    return Output(
      completedTaskCount: completedTaskCount,
      completedTaskStatus: completedTaskStatus,
      monthText: selectedMonthText,
      dataSource: dataSource,
      selectedCalendarDay: calendarDaySelected,
      settingsButtonClicked: settingsButtonClicked,
      completedTasksGroupedByType: completedTasksGroupedByType
    )
    
  }
  
  func getDayText(tasksCount: Int) -> String {
    switch tasksCount {
    case 0:
      return "Нужно взять себя в руки! Давай-ка поднажмём?"
    case 1...3:
      return "Уже неплохо, у тебя все получится!"
    case 4...6:
      return "Ты просто герой, горжусь тобой!"
    case 7...10:
      return "Нереально, просто пушка!"
    case 11... .max():
      return "Человеку это вообще под силу?"
    default:
      return ""
    }
  }

}

