//
//  OverdueTaskCollectionViewCellModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 16.06.2021.
//

import RxFlow
import RxSwift
import RxCocoa
import Foundation
import SwipeCellKit

class OverdueTaskCollectionViewCellModel: Stepper {
    let disposeBag = DisposeBag()
    let steps = PublishRelay<Step>()
    let task = BehaviorRelay<Task?>(value: nil)

    let services: AppServices

    init(services: AppServices, task: Task) {
        self.services = services
        self.task.accept(task)
    }

    func addTaskButtonClick() {
        if let task = task.value {
            task.status = .created
            task.createdTimeIntervalSince1970 = Date().timeIntervalSince1970
            services.coreDataService.saveTasksToCoreData(tasks: [task]) { error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            }
        }
    }
}

extension OverdueTaskCollectionViewCellModel: SwipeCollectionViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: nil) { [weak self] action, _ in
            guard let self = self else { return }
            action.fulfill(with: .reset)

            if let task = self.task.value {
                task.status = .deleted
                self.services.coreDataService.saveTasksToCoreData(tasks: [task]) { error in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                }
            }
        }

        let ideaBoxAction = SwipeAction(style: .default, title: nil) { [weak self] action, _ in
            guard let self = self else { return }
            action.fulfill(with: .reset)
            if let task = self.task.value {
                task.status = .idea
                self.services.coreDataService.saveTasksToCoreData(tasks: [task]) { error in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                }
            }
        }

        deleteAction.backgroundColor = .red
        deleteAction.transitionDelegate = ScaleTransition.default
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.textColor = .white

        ideaBoxAction.backgroundColor = .systemOrange
        ideaBoxAction.transitionDelegate = ScaleTransition.default
        ideaBoxAction.image = UIImage(systemName: "archivebox")
        ideaBoxAction.textColor = .white

        return [deleteAction, ideaBoxAction]
    }

    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
}
