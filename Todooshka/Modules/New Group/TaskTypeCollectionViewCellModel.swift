//
//  TaskTypeCollectionViewCellModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 04.08.2021.
//


import RxFlow
import RxSwift
import RxCocoa
import Foundation
import SwipeCellKit


class TaskTypeCollectionViewCellModel: Stepper {
    
    private let services: AppServices
    
    let disposeBag = DisposeBag()
    let steps = PublishRelay<Step>()
    
    let formatter = DateFormatter()
    let type = BehaviorRelay<TaskType?>(value: nil)
    let isSelected = BehaviorRelay<Bool?>(value: nil)
    //MARK: - Из модели во Вью Контроллер
    init(services: AppServices, type: TaskType) {
        self.services = services
        self.type.accept(type)
        
        services.coreDataService.selectedTaskType.bind{[weak self] type in
            guard let self = self else { return }
            if type == self.type.value {
                self.isSelected.accept(true)
            } else {
                self.isSelected.accept(false)
            }
        }.disposed(by: disposeBag)
    }
}

