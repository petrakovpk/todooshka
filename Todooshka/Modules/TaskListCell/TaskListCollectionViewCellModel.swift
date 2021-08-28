//
//  TaskListCellViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 20.05.2021.
//

import RxFlow
import RxSwift
import RxCocoa
import Foundation
import SwipeCellKit

class TaskListCollectionViewCellModel: Stepper {
    
    private let services: AppServices
    
    let disposeBag = DisposeBag()
    let steps = PublishRelay<Step>()
    
    let formatter = DateFormatter()
    
    //MARK: - Из модели во Вью Контроллер
    let taskTextOutput = BehaviorRelay<String?>(value: nil)
    let taskTypeOutput = BehaviorRelay<TaskType?>(value: nil)
    let timeLeftOutput = BehaviorRelay<Date?>(value: nil)
    let timeLeftPercentOutput = BehaviorRelay<Double?>(value: nil)
    
    let taskTimeLeftTextOutput = BehaviorRelay<String>(value: "")
    let task = BehaviorRelay<Task?>(value: nil)
    
    var isEnabled = true
    
    
    //MARK: - Init
    init(services: AppServices, task: Task) {
        self.services = services
        self.task.accept(task)
        
        services.coreDataService.taskTypes.bind{ [weak self] types in
            guard let self = self else { return }
            if let type = types.first(where: {$0.UID == task.type}) {
                self.taskTypeOutput.accept(type)
            }
        }.disposed(by: disposeBag)
        
        self.task.bind{ [weak self] task in
            guard let self = self else { return }
            guard let task = task else { return }
            self.taskTextOutput.accept(task.text)
                        
            let secondsLeftTimeIntervalSince1970 = task.createdTimeIntervalSince1970 - Date().timeIntervalSince1970 + 24 * 60 * 60
            self.timeLeftOutput.accept(Date(timeIntervalSince1970: secondsLeftTimeIntervalSince1970))
            self.timeLeftPercentOutput.accept(secondsLeftTimeIntervalSince1970 / (24 * 60 * 60))
        }.disposed(by: disposeBag)
        
        Observable<Int>.timer(RxTimeInterval.seconds(0), period: RxTimeInterval.seconds(1), scheduler: MainScheduler.instance).subscribe { [weak self] _ in
            guard let self = self else { return }
            guard let task = self.task.value else { return }
            guard let timeLeftOutput = self.timeLeftOutput.value else { return }
            
            let secondsLeftTimeIntervalSince1970 = task.createdTimeIntervalSince1970 - Date().timeIntervalSince1970 + 24 * 60 * 60
            let timeLeft = Date(timeIntervalSince1970: secondsLeftTimeIntervalSince1970)
                        
            if timeLeft.hour != timeLeftOutput.hour || timeLeft.minute != timeLeftOutput.minute {
                self.timeLeftOutput.accept(timeLeft)
                self.timeLeftPercentOutput.accept(secondsLeftTimeIntervalSince1970 / (24 * 60 * 60))
            }
        }.disposed(by: disposeBag)
        
        formatter.dateFormat = "HH'h' mm'm'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        self.timeLeftOutput.bind{[weak self] time in
            guard let self = self else { return }
            guard let time = time else { return }
            
            self.taskTimeLeftTextOutput.accept(self.formatter.string(from: time))
        }.disposed(by: disposeBag)
    }
    
    //MARK: - Handlers
    func repeatButtonClick() {
        if let task = self.task.value {
            task.status = .created
            task.createdTimeIntervalSince1970 = Date().timeIntervalSince1970
            task.closedTimeIntervalSince1970 = nil
            services.coreDataService.saveTasksToCoreData(tasks: [task], completion: nil)
        }
    }
    
}


extension TaskListCollectionViewCellModel: SwipeCollectionViewCellDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willBeginEditingItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) {
        isEnabled = false
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndEditingItemAt indexPath: IndexPath?, for orientation: SwipeActionsOrientation) {
        isEnabled = true
    }
    
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: nil) { [weak self] action, indexPath in
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
        
        let ideaBoxAction = SwipeAction(style: .default, title: nil) { [weak self] action, indexPath in
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
        
        let completeTaskAction = SwipeAction(style: .default, title: nil) { [weak self] action, indexPath in
            guard let self = self else { return }
            action.fulfill(with: .reset)
            if let task = self.task.value {
                task.status = .completed
                task.closedTimeIntervalSince1970 = Date().timeIntervalSince1970
                self.services.coreDataService.saveTasksToCoreData(tasks: [task]) { error in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                }
            }
        }
        
        configure(action: deleteAction, with: .trash)
        configure(action: ideaBoxAction, with: .idea)
        configure(action: completeTaskAction, with: .complete)
        
        deleteAction.backgroundColor = Style.haiti
        ideaBoxAction.backgroundColor = Style.haiti
        completeTaskAction.backgroundColor = Style.haiti
        
        return [completeTaskAction, deleteAction, ideaBoxAction]
    }
    
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        options.buttonSpacing = 4
        return options
    }
    
    func configure(action: SwipeAction, with descriptor: ActionDescriptor) {
        let buttonDisplayMode: ButtonDisplayMode = .imageOnly
        let buttonStyle: ButtonStyle = .circular
        
        action.title = descriptor.title(forDisplayMode: buttonDisplayMode)
        action.image = descriptor.image(forStyle: buttonStyle, displayMode: buttonDisplayMode)
        
        switch buttonStyle {
        case .backgroundColor:
            action.backgroundColor = descriptor.color(forStyle: buttonStyle)
        case .circular:
            action.backgroundColor = .clear
            action.textColor = descriptor.color(forStyle: buttonStyle)
            action.font = .systemFont(ofSize: 9)
            action.transitionDelegate = ScaleTransition.default
        }
    }
    
    func circularIcon(with color: UIColor, size: CGSize, icon: UIImage? = nil) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        UIBezierPath(ovalIn: rect).addClip()
        
        color.setFill()
        UIRectFill(rect)
        
        if let icon = icon {
            let iconRect = CGRect(x: (rect.size.width - icon.size.width) / 2,
                                  y: (rect.size.height - icon.size.height) / 2,
                                  width: icon.size.width,
                                  height: icon.size.height)
            icon.draw(in: iconRect, blendMode: .normal, alpha: 1.0)
        }
        
        defer { UIGraphicsEndImageContext() }
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
}

