//
//  FunViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 18.11.2022.
//
import Foundation
import RxFlow
import RxSwift
import RxCocoa

class FunViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  
  private let services: AppServices
  private let disposeBag = DisposeBag()
  
  struct Input {
    let viewDidLoad: Observable<Void>
  }
  
  struct Output {
    let dataSource: Driver<[FunSection]>
  }
  
  init(services: AppServices) {
    self.services = services
  }
  
  func transform(input: Input) -> Output {
    let dataSource = input.viewDidLoad
      .flatMapLatest { [unowned self] _ -> Observable<[FunSection]> in
        self.services.userAPIService.fetchRecommendedTasks()
          .flatMap { tasks -> Observable<[FunItem]> in
            let taskObservables = tasks.map { task -> Observable<FunItem> in
              let userObservable = self.services.userAPIService.fetchUser(userUID: task.userUID ?? "")
              return Observable.zip(Observable.just(task), userObservable)
                .debug()
                .flatMap { (task, author) -> Observable<FunItem> in
                  print("1234", task, author)
                  return self.services.taskAPIService.fetchTaskImage(taskID: task.uuid)
                    .map { image -> FunItem in
                      FunItem(author: author, task: task, image: image ?? UIImage())
                    }
                }
            }
            return Observable.zip(taskObservables)
          }
          .map { funItems -> [FunSection] in
            return [FunSection(header: "", items: funItems)]
          }
      }
      .asDriver(onErrorJustReturn: [])
      .debug()
    
    return Output(dataSource: dataSource)
  }
}
