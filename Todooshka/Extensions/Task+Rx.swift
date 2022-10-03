//
//  Task+Rx.swift
//  Todooshka
//
//  Created by Pavel Petakov on 15.09.2022.
//

import RxCocoa
import RxSwift


extension SharedSequence where Element == Task {
  
  func change(closed date: Date) -> RxCocoa.SharedSequence<SharingStrategy, Task> {
    return self.map { task in
      var task = task
      task.closed = date
      return task
    }
  }
  
  func change(created date: Date) -> RxCocoa.SharedSequence<SharingStrategy, Task> {
    return self.map { task in
      var task = task
      task.created = date
      return task
    }
  }
  
  func change(planned date: Date?) -> RxCocoa.SharedSequence<SharingStrategy, Task> {
    return self.map { task in
      var task = task
      task.planned = date
      return task
    }
  }
  
  func change(status: TaskStatus) -> RxCocoa.SharedSequence<SharingStrategy, Task> {
    return self.map { task in
      var task = task
      task.status = status
      return task
    }
  }
  
}


