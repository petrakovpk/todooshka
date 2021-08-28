//
//  UserProfileTaskCollectionViewCellModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 10.06.2021.
//


import RxFlow
import RxSwift
import RxCocoa
import Foundation
import SwipeCellKit

class UserProfileTaskCollectionViewCellModel: Stepper {
    
    let disposeBag = DisposeBag()
    let steps = PublishRelay<Step>()
    let taskRelay = BehaviorRelay<Task?>(value: nil)
    let task: Task
    
    private let services: AppServices
    
    init(services: AppServices, task: Task) {
        self.services = services
        self.task = task
        taskRelay.accept(task)
    }
    
}

extension UserProfileTaskCollectionViewCellModel: SwipeCollectionViewCellDelegate {
    
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: nil) { [unowned self] action, indexPath in
            services.networkDatabaseService.removeTaskFromDatabase(task: task) { error, ref in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            }
        }
        
        deleteAction.backgroundColor = TDStyle.Colors.backgroundColor
        deleteAction.transitionDelegate = ScaleTransition.default
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.textColor = .red
        
        return [deleteAction]
    }
    
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
}

