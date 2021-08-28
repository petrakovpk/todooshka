//
//  IdeaBoxTaskListViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 09.07.2021.
//


import RxFlow
import RxSwift
import RxCocoa
import Firebase

class IdeaBoxTaskListViewModel: Stepper {
    
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
        
        services.coreDataService.tasks.map({$0.filter{ $0.status == .idea }}).bind { [weak self] tasks in
            guard let self = self else { return }
            
            let tasksDict = Dictionary(grouping: tasks, by: {$0.type }).sorted{ $0.key > $1.key }
            
            var models: [TaskListSectionModel] = []
            
            for taskDict in tasksDict {
                models.append(TaskListSectionModel(header: taskDict.key, items: taskDict.value))
            }
            self.dataSource.accept(models)

        }.disposed(by: disposeBag)
    }
    
    func openTask(indexPath: IndexPath) {
        let task = dataSource.value[indexPath.section].items[indexPath.item]
        steps.accept(AppStep.showTaskIsRequired(task: task))
    }
    
    func leftBarButtonBackItemClick() {
        steps.accept(AppStep.ideaBoxTaskListIsCompleted)
    }
    
    func rightBarButtonAddItemClick() {
        steps.accept(AppStep.createTaskIsRequired(status: .idea, createdDate: nil) )
    }
}
