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
    let typeLabel1TextOutput = BehaviorRelay<String>(value: "")
    let typeLabel2TextOutput = BehaviorRelay<String>(value: "")
    let typeLabel3TextOutput = BehaviorRelay<String>(value: "")
    let typeLabel4TextOutput = BehaviorRelay<String>(value: "")
    
    init(services: AppServices) {
        self.services = services
        
        services.networkAuthService.currentUser.bind{ [weak self] user in
            guard let self = self else { return }
            guard let user = user else { return }
                        
        }.disposed(by: disposeBag)
        
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
                .bind{ completedTasks in
                    let completedTasksDict = Dictionary(grouping: completedTasks, by: { $0.type }).sorted{ $0.value.count > $1.value.count }
 
                    self.completedTasksLabelOutput.accept(completedTasks.count.string)
                    
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
    
    func updateDataSource(deltaMonth: Int, tasks: [Task]) {
        
    }
    
    func daySelected(indexPath: IndexPath) {
        if let calendarDate = dataSource.value.first?.items[indexPath.item],
           calendarDate.isSelectedMonth == true {
            services.coreDataService.calendarSelectedDate.accept(calendarDate.date)
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
