//
//  DeletedTasksListViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 05.07.2021.
//

import RxFlow
import RxSwift
import RxCocoa
import Firebase

class DeletedTasksListViewModel: Stepper {
    
    let steps = PublishRelay<Step>()
    let dataSource = BehaviorRelay<[TaskListSectionModel]>(value: [])
    let disposeBag = DisposeBag()
    let services: AppServices
    let formatter = DateFormatter()
        
    init(services: AppServices) {
        self.services = services
        
        formatter.dateFormat = "d MMMM yyyy"
        formatter.timeZone =  TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "ru")
        
        services.coreDataService.tasks.map({$0.filter{$0.status == .deleted }}).bind { [weak self] tasks in
            guard let self = self else { return }
            
            let tasksDict = Dictionary(grouping: tasks , by: {$0.createdDate.beginning(of: .day)}).sorted{ $0.key! > $1.key! }
            
            self.dataSource.accept([])
            for taskDict in tasksDict {
                guard let header = taskDict.key?.dateString(ofStyle: .medium) else { continue }
                let taskListSectionModel = TaskListSectionModel(header: header, items: taskDict.value) 
                self.dataSource.accept(self.dataSource.value + [taskListSectionModel])
            }

        }.disposed(by: disposeBag)
    }
    
    func openTask(indexPath: IndexPath) {
        let task = dataSource.value[indexPath.section].items[indexPath.item]
        steps.accept(AppStep.showTaskIsRequired(task: task) )
    }
    
    func leftBarButtonBackItemClick() {
        steps.accept(AppStep.deletedTaskListIsCompleted)
    }
    
    func alertButtonClick(buttonIndex: Int){
        switch buttonIndex {
        case 1:
            
            if Auth.auth().currentUser == nil {
                services.coreDataService.removeTasksFromCoreData(tasks: dataSource.value.flatMap{ return $0.items }) { error in
                    if let error = error {
                        print(error)
                        return
                    }
                }
            } else {
                var tasks = dataSource.value.flatMap{ return $0.items }
                tasks = tasks.map{ task in
                    let task = task
                    task.status = .hardDeleted
                    return task
                }
                
                services.coreDataService.saveTasksToCoreData(tasks: tasks) { error in
                    if let error = error {
                        print(error)
                        return
                    }
                }
            }
            
            
        default:
            print(buttonIndex)
        }
    }
    
}
