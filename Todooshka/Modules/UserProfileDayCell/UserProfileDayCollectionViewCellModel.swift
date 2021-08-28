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
    
    let disposeBag = DisposeBag()
    let steps = PublishRelay<Step>()
    let services: AppServices
    
    //MARK: - Output
    let calendarDay = BehaviorRelay<CalendarDay?>(value: nil)
    let isSelectedDay = BehaviorRelay<Bool>(value: false)
    let isToday = BehaviorRelay<Bool>(value: false)
    let roundViewCount = BehaviorRelay<Int>(value: 0)
    
    init(services: AppServices, calendarDay: CalendarDay) {
        self.services = services
        self.calendarDay.accept(calendarDay)
        
        services.coreDataService.calendarSelectedDate.bind{ [weak self] selectedDate in
            guard let self = self else { return }
            if Calendar.current.isDate(selectedDate, inSameDayAs: calendarDay.date) {
                self.isSelectedDay.accept(true)
            } else {
                self.isSelectedDay.accept(false)
            }
        }.disposed(by: disposeBag)
        
        if calendarDay.date.isInToday {
            self.isToday.accept(true)
        } else {
            self.isToday.accept(false)
        }
        
        self.services.coreDataService.tasks
            .map { tasks -> [Task] in
                var tasks = tasks.filter{ $0.status == .completed }
                tasks = tasks.filter{ task in
                    guard let closedDate = task.closedDate else { return false }
                    return Calendar.current.isDate(calendarDay.date, inSameDayAs: closedDate)
                }
                return tasks
            }
            .bind{ completedTasks in
                
                switch completedTasks.count {
                case 1:
                    self.roundViewCount.accept(1)
                case 2...3:
                    self.roundViewCount.accept(2)
                case 4... :
                    self.roundViewCount.accept(3)
                default:
                    self.roundViewCount.accept(0)
                }
                
            }.disposed(by: self.disposeBag)
        
    }
    
}
