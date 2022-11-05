//
//  RxTask.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 01.03.2022.
//

import RxSwift
import RxCocoa
import UIKit

public struct TaskDriverSharingStrategy: SharingStrategyProtocol {
    public static var scheduler: SchedulerType { SharingScheduler.make() }
    public static func share<Task>(_ source: Observable<Task>) -> Observable<Task> {
        source.share(replay: 1, scope: .whileConnected)
    }
}
