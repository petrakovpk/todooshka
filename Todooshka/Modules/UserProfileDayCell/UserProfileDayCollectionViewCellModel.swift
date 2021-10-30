//
//  UserProfileDayCollectionViewCellModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.06.2021.
//


import RxFlow
import RxSwift
import RxCocoa
import Foundation

class UserProfileDayCollectionViewCellModel: Stepper {
  
  //MARK: - Properties
  let steps = PublishRelay<Step>()
  let services: AppServices
  let calendarDay: CalendarDay
  
  struct Output {
    let text: Driver<String>
    let alpha: Driver<CGFloat>
    let backgroundColor: Driver<UIColor>
    let textColor: Driver<UIColor>
    let borderWidth: Driver<CGFloat>
    let roundsCount: Driver<Int>
  }
  
  //MARK: - Init
  init(services: AppServices, calendarDay: CalendarDay) {
    self.services = services
    self.calendarDay = calendarDay
  }
  
  //MARK: - Transform
  func transform() -> Output {
    
    let text = Driver<String>.just(calendarDay.date.day.string)
    
    let alpha = services.coreDataService.calendarSelectedMonth
      .map{ CGFloat($0.month == self.calendarDay.date.month ? 1 : 0.4) }
      .asDriver(onErrorJustReturn: 0.4)
    
    let isSelected = services.coreDataService.calendarSelectedDate
      .map{ Calendar.current.isDate($0, inSameDayAs: self.calendarDay.date) }
      .asDriver(onErrorJustReturn: false)
    
    let backgroundColor = isSelected
      .map { $0 ? UIColor.blueRibbon : UIColor.clear }
    
    let textColor = isSelected
      .map { $0 ? UIColor.white : UIColor(named: "appText")! }
    
    let borderWidth = Driver<CGFloat>
      .just( Calendar.current.isDate(Date(), inSameDayAs: self.calendarDay.date) ? 1 : 0)
    
    let completedTasks = services.coreDataService.tasks
      .map { tasks -> [Task] in
        let tasks = tasks
          .filter{ $0.status == .completed }
          .filter{ Calendar.current.isDate(
            self.calendarDay.date, inSameDayAs: $0.closedDate ?? Date(timeIntervalSince1970: 4096980573000 ))}
        return tasks
      }.asDriver(onErrorJustReturn: [])
    
    let roundsCount = completedTasks
      .map{ tasks -> Int in
        if tasks.count == 1 { return 1 }
        if 2 ... 3 ~= tasks.count { return 2 }
        if 4 ... .max  ~= tasks.count { return 3 }
        return 0
      }
    
    
    return Output(
      text: text,
      alpha: alpha,
      backgroundColor: backgroundColor,
      textColor: textColor,
      borderWidth: borderWidth,
      roundsCount: roundsCount
    )
  }
  
}
