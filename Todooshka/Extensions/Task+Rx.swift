//
//  Task+Rx.swift
//  Todooshka
//
//  Created by Pavel Petakov on 15.09.2022.
//

import RxCocoa
import RxSwift


extension SharedSequence where Element == Task {
  
  func change(with status: TaskStatus) -> RxCocoa.SharedSequence<SharingStrategy, Task> {
    return self.map { task in
      var task = task
      task.status = status
      return task
    }
  }
    
    func change(with closed: Date) -> RxCocoa.SharedSequence<SharingStrategy, Task> {
      return self.map { task in
        var task = task
        task.closed = closed
        return task
      }
  }
}


