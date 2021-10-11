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
  let dataSource = BehaviorRelay<[UserProfileSectionModel]>(value: [])
  let disposeBag = DisposeBag()
  
  let deltaMonth = BehaviorRelay<Int>(value: 0)
  
  let services: AppServices
  
  //MARK: - Outputs
  let completedTasksLabelOutput = BehaviorRelay<String>(value: "")
  let dayStatusTextOutput = BehaviorRelay<String>(value: "")
  let typeLabel1TextOutput = BehaviorRelay<String>(value: "")
  let typeLabel2TextOutput = BehaviorRelay<String>(value: "")
  let typeLabel3TextOutput = BehaviorRelay<String>(value: "")
  let typeLabel4TextOutput = BehaviorRelay<String>(value: "")
  
  init(services: AppServices) {
    self.services = services
    
    deltaMonth.bind { [weak self] deltaMonth in
      guard let self = self else { return }
      
      let startOfMonthDate = Date().adding(.month, value: deltaMonth).startOfMonth
      let endOfMonthDate = Date().adding(.month, value: deltaMonth).endOfMonth
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
      
      self.dataSource.accept([UserProfileSectionModel(header: "", items: items)])
    }.disposed(by: disposeBag)
    
    
    services.coreDataService.calendarSelectedDate.bind{ [weak self] date in
      guard let self = self else { return }
      
      self.services.coreDataService.tasks
        .map { tasks -> [Task] in
          var tasks = tasks.filter{ $0.status == .completed }
          tasks = tasks.filter{ task in
            guard let closedDate = task.closedDate else { return false }
            return Calendar.current.isDate(date, inSameDayAs: closedDate)
          }
          return tasks
        }
        .bind { completedTasks in
          let completedTasksDict = Dictionary(grouping: completedTasks, by: { $0.type?.text ?? "" }).sorted{ $0.value.count > $1.value.count }
          
          self.completedTasksLabelOutput.accept( completedTasksDict.flatMap{ $0.value }.count.string )
          self.dayStatusTextOutput.accept( self.getDayText( tasksCount: completedTasksDict.flatMap{ $0.value }.count  ))
          
          if let firstType = completedTasksDict[safe: 0] {
            self.typeLabel1TextOutput.accept("\(firstType.key): \(firstType.value.count)")
          } else {
            self.typeLabel1TextOutput.accept("")
          }
          
          if let secondType = completedTasksDict[safe: 1] {
            self.typeLabel2TextOutput.accept("\(secondType.key): \(secondType.value.count)")
          } else {
            self.typeLabel2TextOutput.accept("")
          }
          
          if let thirdType = completedTasksDict[safe: 2] {
            self.typeLabel3TextOutput.accept("\(thirdType.key): \(thirdType.value.count)")
          } else {
            self.typeLabel3TextOutput.accept("")
          }
          
          if let fourthType = completedTasksDict[safe: 3] {
            self.typeLabel4TextOutput.accept("\(fourthType.key): \(fourthType.value.count)")
          } else {
            self.typeLabel4TextOutput.accept("")
          }
          
        }.disposed(by: self.disposeBag)
    }.disposed(by: self.disposeBag)
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
  
  //MARK: - Handlers
  func daySelected(indexPath: IndexPath) {
    if let calendarDate = dataSource.value.first?.items[indexPath.item],
       calendarDate.isSelectedMonth == true {
      if calendarDate.date == services.coreDataService.calendarSelectedDate.value {
        steps.accept(AppStep.completedTaskListIsRequired(date: calendarDate.date))
      } else {
        services.coreDataService.calendarSelectedDate.accept(calendarDate.date)
      }
    }
  }
  
  func settingsButtonClicked() {
    steps.accept(AppStep.userSettingsIsRequired)
  }
  
  func ideaBoxButtonClicked() {
    steps.accept(AppStep.ideaBoxTaskListIsRequired)
  }
  
  func completedTasksClicked() {
    let date = services.coreDataService.calendarSelectedDate.value
    steps.accept(AppStep.completedTaskListIsRequired(date: date))
  }
  
  func previousMonthButtonClicked() {
    deltaMonth.accept(deltaMonth.value - 1)
  }
  
  func nextMonthButtonClicked() {
    deltaMonth.accept(deltaMonth.value + 1)
  }
}

