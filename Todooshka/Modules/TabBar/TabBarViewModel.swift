//
//  TabBarViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 28.07.2021.
//


import RxFlow
import RxSwift
import RxCocoa
import Firebase

class TabBarViewModel: Stepper {
    
    let steps = PublishRelay<Step>()
    let disposeBag = DisposeBag()
    let services: AppServices
    
    init(services: AppServices) {
        self.services = services
    }
    
    func handleAddTaskClick() {
        steps.accept(AppStep.createTaskIsRequired(status: .created, createdDate: nil) )
    }
}
