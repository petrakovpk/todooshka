//
//  Observable.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 06.04.2022.
//
import RxSwift
import RxCocoa

extension ObservableType {
  
  // withPrevious
  func withPrevious(startWith first: Element) -> Observable<(previous: Element, current: Element)> {
        return scan((first, first)) { ($0.1, $1) }.skip(1)
    }
}

extension ObservableType where Element == Task {
  
  // close
  func close() -> Observable<Task> {
    return self.map { task in
      var task = task
      task.status = .Completed
      task.closed = Date()
      return task
    }
  }
  
  // save
  func save(with service: HasTasksService) -> Observable<Task> {
    return self.do( onNext: { task in
      service.tasksService.saveTasksToCoreData(tasks: [task])
    })
  }
}
