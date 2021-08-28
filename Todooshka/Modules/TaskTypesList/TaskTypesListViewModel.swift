//
//  TaskTypesListViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 24.06.2021.
//

import RxFlow
import RxSwift
import RxCocoa
import Firebase

class TaskTypesListViewModel: Stepper {
    
    //MARK: - Properties
    let steps = PublishRelay<Step>()
    let dataSource = BehaviorRelay<[TaskTypesListSectionModel]>(value: [])
    let taskTypes = BehaviorRelay<[TaskType]>(value: [])
    let disposeBag = DisposeBag()
    let services: AppServices
    let formatter = DateFormatter()
    let isLoadingOutput = BehaviorRelay<Bool>(value: false)
    
    //MARK: - Init
    init(services: AppServices) {
        self.services = services 
        
        dataSource.accept([TaskTypesListSectionModel(header: "", items: services.coreDataService.taskTypes.value)])
        taskTypes.accept(services.coreDataService.taskTypes.value)
        
        taskTypes.bind{ [weak self] types in
            guard let self = self else { return }

            self.services.coreDataService.saveTaskTypesToCoreData(types: types, completion: nil)
            
        }.disposed(by: disposeBag)
        
    }
    
    //MARK: - Handlers
    func leftBarButtonBackItemClick(){
        steps.accept(AppStep.taskTypesListIsCompleted)
    }
    
    func typeSelected(indexPath: IndexPath) {
        guard let type = services.coreDataService.taskTypes.value[safe: indexPath.item] else { return }
        steps.accept(AppStep.taskTypesListIsCompleted)
    }
    
    func tableRowMoved(sourceIndex: IndexPath, destinationIndex: IndexPath) {
        guard sourceIndex != destinationIndex else { return }
        var taskTypes = taskTypes.value
            
        let element = taskTypes.remove(at: sourceIndex.row)
        taskTypes.insert(element, at: destinationIndex.row)
        
        for (index, _) in taskTypes.enumerated() {
            taskTypes[index].orderNumber = index
        }
        
        self.taskTypes.accept(taskTypes)
        
    }
    
    
}
